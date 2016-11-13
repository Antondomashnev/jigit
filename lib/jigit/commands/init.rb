require "yaml"
require "jigit/jira/jira_config"
require "jigit/jira/jira_api_client"
require "jigit/jira/resources/jira_status"
require "jigit/core/jigitfile_generator"
require "jigit/git/git_hook_installer"
require "jigit/git/git_ignore_updater"
require "jigit/git/post_checkout_hook"
require "jigit/helpers/keychain_storage"

module Jigit
  # This class is heavily based on the Init command from the Danger gem
  # The original link is https://github.com/danger/danger/blob/master/lib/danger/commands/init.rb
  class Init < Runner
    attr_accessor :current_jira_config

    self.summary = "Helps you set up Jigit."
    self.command = "init"
    self.abstract_command = false

    def self.options
      [
        ["--impatient", "'I've not got all day here. Don't add any thematic delays please.'"],
        ["--mousey", "'Don't make me press return to continue the adventure.'"]
      ].concat(super)
    end

    def initialize(argv)
      super
      ui.no_delay = argv.flag?("impatient", false)
      ui.no_waiting = argv.flag?("mousey", false)
    end

    def run
      ui.say "\nOK, thanks #{ENV['LOGNAME']}, have a seat and we'll get you started.\n".yellow
      ui.pause 1

      show_todo_state
      ui.pause 1.4

      return unless setup_access_to_jira
      return unless setup_jigitfile
      return unless setup_post_checkout_hook
      return unless setup_gitignore

      info
      thanks
    end

    def show_todo_state
      ui.say "We need to do the following:\n"
      ui.pause 0.6
      ui.say " - [ ] Set up an access to JIRA."
      ui.pause 0.6
      ui.say " - [ ] Set up a Jigit configuration file."
      ui.pause 0.6
      ui.say " - [ ] Set up a git hooks to automate the process."
      ui.pause 0.6
      ui.say " - [ ] Add private jigit's related things to .gitignore."
    end

    def ask_for_jira_account_email
      ui.ask("What's is your JIRA's account email").strip
    end

    def ask_for_jira_account_password(email)
      ui.ask("What's is the password for #{email}").strip
    end

    def ask_for_jira_host(polite)
      return ui.ask("What's is the host for your JIRA server").strip unless polite

      ui.say "\nThanks, and the last one is a bit tricky. Jigit needs the " + "host".green + " of your JIRA server.\n"
      ui.pause 0.6
      ui.say "The easiest way to get it is to go to your JIRA website and check the browser address field.\n"
      ui.pause 0.6
      ui.say "Usually it looks like " + "your_company_name.atlassian.net".green + ".\n"
      ui.pause 0.6
      ui.ask("What's is the host for your JIRA server").strip
    end

    def validate_jira_config?(config)
      is_valid = Jigit::JiraAPIClient.new(config, nil).validate_api?
      if is_valid
        ui.inform "Hooray 🎉, everything is green.\n"
        return true
      else
        ui.error "Yikes 😕\n"
        ui.say "Let's try once again, you can do it 💪\n"
        return false
      end
    rescue Jigit::JiraAPIClientError
      ui.error "Yikes 😕\n"
      ui.say "Let's try once again, you can do it 💪\n"
      return false
    end

    def build_jira_config_politely(politely)
      email = ask_for_jira_account_email
      password = ask_for_jira_account_password(email)
      host = ask_for_jira_host(politely)

      ui.say "\nThanks, let's validate if the Jigit has access now...\n" if politely
      config = Jigit::JiraConfig.new(email, password, host)
      if validate_jira_config?(config)
        config
      else
        build_jira_config_politely(false)
      end
    rescue Jigit::NetworkError => exception
      ui.error "Error while validating access to JIRA API: #{exception.message}"
      return nil
    end

    def setup_access_to_jira
      ui.header "\nStep 1: Setting up an access to JIRA"
      ui.pause 0.6
      ui.say "In order to Jigit to be able to help you, it needs access to your JIRA account.\n"
      ui.pause 0.6
      ui.say "But don't worry it'll store it in a safe place.\n"
      ui.pause 1

      self.current_jira_config = build_jira_config_politely(true)
      if self.current_jira_config
        keychain_storage = Jigit::KeychainStorage.new
        keychain_storage.save(self.current_jira_config.user, self.current_jira_config.password, self.current_jira_config.host)
        ui.say "Let's move to next step, press return when ready..."
        ui.wait_for_return
        return true
      else
        return false
      end
    end

    def fetch_jira_status_names
      ui.say "Fetching all possible statuses from JIRA...\n"
      jira_api_client = Jigit::JiraAPIClient.new(self.current_jira_config, nil)
      begin
        all_statuses = jira_api_client.fetch_jira_statuses
        if all_statuses.nil? || all_statuses.count.zero?
          ui.error "Yikes 😕\n"
          ui.say "Jigit can not find any statuses for JIRA issue in your company setup.\n"
          return nil
        else
          all_statuses.map(&:name)
        end
      rescue Jigit::JiraAPIClientError => exception
        ui.error "Error while fetching statuses from JIRA API: #{exception.message}"
        return false
      rescue Jigit::NetworkError => exception
        ui.error "Error while fetching statuses from JIRA API: #{exception.message}"
        return false
      end
    end

    def handle_nicely_setup_jigitfile_failure
      ui.say "Unfortunately, Jigit can not proceed without that information.\n"
      ui.pause 0.6
      ui.say "Try to check the JIRA setup and your internet connection status.\n"
      ui.pause 0.6
      ui.say "If everything looks fine, try to init Jigit once egain: `bundle exec jigit init`"
    end

    def ask_for_in_progress_status_name(status_names)
      in_progress_status_name = ui.ask_with_answers("What status do you set when work on the JIRA issue\n", status_names)
      in_progress_status_name
    end

    def ask_for_other_status_names(status_names)
      not_asked_status_names = status_names
      selected_status_names = []
      ui.say "Now Jigit needs to know, what status could you set when stop working on the issue.\n"
      ui.pause 0.6
      ui.say "We know you can have multiple, don't worry  and"
      ui.pause 0.6
      ui.say "when you're done select 'nothing' option.\n"
      ui.pause 1

      selected_status_name = nil
      loop do
        selected_status_names << selected_status_name unless selected_status_name.nil?
        break if not_asked_status_names.count.zero?
        selected_status_name = ui.ask_with_answers("Which one you want to select", not_asked_status_names + ["nothing"])
        break if selected_status_name == "nothing"
        ui.say selected_status_name
        not_asked_status_names.delete(selected_status_name)
      end
      return selected_status_names
    end

    def setup_jigitfile
      jigitfile_generator = Jigit::JigitfileGenerator.new

      ui.header "Step 2: Setting up a Jigit configuration file"
      ui.say "In order to Jigit to be able to help you it needs to know something about your usual workflow.\n"
      ui.pause 1

      jira_status_names = fetch_jira_status_names
      unless jira_status_names
        handle_nicely_setup_jigitfile_failure
        return false
      end
      ui.pause 0.6

      jigitfile_generator.write_jira_host(self.current_jira_config.host)
      ui.pause 0.6

      in_progress_status_name = ask_for_in_progress_status_name(jira_status_names)
      jigitfile_generator.write_in_progress_status_name(in_progress_status_name)
      ui.pause 0.6

      selected_status_names = ask_for_other_status_names(jira_status_names)
      jigitfile_generator.write_other_statuses(selected_status_names)
      ui.pause 0.6

      jigitfile_generator.save

      ui.say "And the jigitfile is ready 🎉.\n"
      ui.say "You can find it at './.jigit/Jigitfile.yml'"
      ui.pause 0.6
      ui.say "Let's move to next step, press return when ready..."
      ui.wait_for_return
      return true
    end

    def setup_post_checkout_hook
      ui.header "Step 3: Setting up a git hooks to automate the process."
      ui.say "Jigit is going to create a post-checkout git hook."
      ui.pause 0.6
      ui.say "It will the 'git checkout' command and if it's a checkout to a branch."
      ui.pause 0.6
      ui.say "Jigit will ask it needs to put the new branch's related issue In Progress"
      ui.pause 0.6
      ui.say "and to update status for the old branch on JIRA"

      git_hook_installer = Jigit::GitHookInstaller.new
      post_checkout_hook = Jigit::PostCheckoutHook
      git_hook_installer.install(post_checkout_hook)

      ui.say "And the git hook is ready 🎉.\n"
      ui.say "You can find it at './.git/hooks/post-checkout'"
      ui.pause 0.6
      ui.say "One last step and we're done, press return to continue..."
      ui.wait_for_return
      return true
    end

    def setup_gitignore
      ui.header "Step 4: Adding private jigit's related things to .gitignore."
      ui.say "Jigit has been setup for your personal usage with your personal info"
      ui.pause 0.6
      ui.say "therefore it can not be really used accross the team, so we need to git ignore the related files."
      ui.pause 0.6

      git_hook_installer = Jigit::GitIgnoreUpdater.new
      git_hook_installer.ignore(".jigit")

      ui.say "And the git ignore now ignores your .jigit folder 🎉.\n"
      ui.pause 0.6
      ui.say "That's all to finish initialization press return"
      ui.wait_for_return
      return true
    end

    def info
      ui.header "Useful info"
      ui.say "- This project is at it's early stage and may be unstable"
      ui.pause 0.6
      ui.say "- If you find any bug or want to add something, you're very welcome to the repo:"
      ui.link "https://github.com/Antondomashnev/jigit"
      ui.pause 0.6
      ui.say "- If you want to know more, follow " + "@antondomashnev".green + " on Twitter"
      ui.pause 1
    end

    def thanks
      ui.say "\n\nHave a happy coding 🎉"
    end
  end
end
