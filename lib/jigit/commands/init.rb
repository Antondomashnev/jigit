require "yaml"
require "jigit/jira/jira_config"
require "jigit/jira/jira_api_client"
require "jigit/jira/resources/jira_status"
require "jigit/core/jigitfile_generator"

module Jigit
  # This class is heavily based on the Init command from the Danger gem
  # The original link is https://github.com/danger/danger/blob/master/lib/danger/commands/init.rb
  class Init < Runner
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

      setup_access_to_jira
      setup_jigitfile

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
    end

    def ask_for_jira_account_email
      ui.ask("What's is your JIRA's account email").strip
    end

    def ask_for_jira_account_password(email)
      ui.ask("What's is the password for #{email}").strip
    end

    def ask_for_jira_host(polite)
      ui.ask("What's is the host for your JIRA server?").strip unless polite

      ui.say "\nThanks, and the last one is a bit tricky. Jigit needs the " + "host".green + " of your JIRA server.\n"
      ui.pause 1
      ui.say "The easiest way to get it is to go to your JIRA website and check the browser address field.\n"
      ui.say "Usually it looks like " + "your_company_name.atlassian.net".green + ".\n"
      ui.pause 1
      ui.ask("What's is the host for your JIRA server").strip
    end

    def validate_jira_account?(email, password, host)
      is_valid = Jigit::JiraAPIClient.new(Jigit::JiraConfig.new(email, password, host), nil, ui).validate_api?
      if is_valid
        ui.inform "Hooray 🎉, everything is green.\n"
        return true
      else
        ui.error "Yikes 😕\n"
        ui.say "Let's try once again, you can do it 💪\n"
        new_email = ask_for_jira_account_email
        new_password = ask_for_jira_account_password(new_email)
        new_host = ask_for_jira_host(false)
        validate_jira_account(new_email, new_password, new_host)
      end
    end

    def setup_access_to_jira
      ui.header "\nStep 1: Setting up an access to JIRA"
      ui.say "In order to Jigit to be able to help you, it needs access to your JIRA account.\n"
      ui.say "But don't worry it'll store it in a safe place.\n"
      ui.pause 1

      email = ask_for_jira_account_email
      password = ask_for_jira_account_password(email)
      host = ask_for_jira_host(true)

      ui.say "\nThanks, let's validate if the Jigit has access now...\n"
      if validate_jira_account?(email, password, host)
        Jigit::JiraConfig.store_jira_config(Jigit::JiraConfig.new(email, password, host))
        ui.say "Let's move to next step, press return when ready..."
        ui.wait_for_return
      end
    end

    def fetch_jira_status_names
      ui.say "Fetching all possible statuses from JIRA...\n"
      jira_api_client = Jigit::JiraAPIClient.new(Jigit::JiraConfig.current_jira_config, nil, ui)
      all_statuses = jira_api_client.fetch_jira_statuses
      if all_statuses.nil? || all_statuses.count == 0
        ui.error "Yikes 😕\n"
        ui.say "Jigit can not find any statuses for JIRA issue in your company setup.\n"
        return nil
      else
        all_statuses.map do |status|
          status.name
        end
      end
    end

    def handle_nicely_setup_jigitfile_failure
      ui.say "Unfortunately, Jigit can not proceed without that information.\n"
      ui.say "Try to check the JIRA setup and your internet connection status.\n"
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
      ui.say "We know you can have multiple, don't worry  and"
      ui.say "when you're done select 'nothing' option.\n"
      ui.pause 1

      selected_status_name = nil
      loop do
        selected_status_names << selected_status_name unless selected_status_name.nil?
        break if not_asked_status_names.count == 0
        selected_status_name = ui.ask_with_answers("Which one you want to select", not_asked_status_names + "nothing")
        break if selected_status_name == "nothing"
        not_asked_status_names.delete(selected_status_name)
      end
      return selected_status_names
    end

    def setup_jigitfile
      jigitfile_generator = Jigit::JigitfileGenerator.new()

      ui.header "Step 1: Setting up a Jigit configuration file"
      ui.say "In order to Jigit to be able to help you it needs to know something about your usual workflow.\n"
      ui.pause 1

      jira_status_names = fetch_jira_status_names
      unless jira_status_names
        handle_nicely_setup_jigitfile_failure
        return
      end
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
      ui.say "Let's move to next step, press return when ready..."
      ui.wait_for_return
    end

    def info
      ui.header "Useful info"
      ui.say "- This project is at it's early stage and may be unstable"
      ui.pause 0.6
      ui.say "- If you find any bug or want to add something, you're very welcome to our repo:"
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
