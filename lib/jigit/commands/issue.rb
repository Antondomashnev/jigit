require "jigit/commands/runner"
require "jigit/jira/jira_api_client"
require "jigit/jira/jira_config"

module Jigit
  class IssueRunner < Runner
    self.abstract_command = false
    self.summary = "Any commands on Jira issue"
    self.command = "issue"

    def initialize(argv)
      @action = argv.shift_argument
      @issue_name = argv.option('name')
      @jira_config = Jigit::JiraConfig.new("antondomashnev+jira1@gmail.com", "Anton2104", "antondomashnevjira1.atlassian.net") # Jigit::JiraConfig.current_jira_config
      @jira_api_client = Jigit::JiraAPIClient.new(@jira_config) if @jira_config
      super
    end

    def validate!
      super
      if @action && !%w(stop start).include?(@action)
        help!("`#{@action}' is not a valid action.")
      end
      help!("Please setup jira config using `jigit init` before using issue command.") unless @jira_config
      help!("Please specify JIRA issue. It must not be nil.") unless @issue_name
    end

    def self.options
      [
        ['stop', 'Use this argument if you want to stop working on the feature. For example after checkouting to another branch'],
        ['start', 'Use this argument if you want to start working on the feature. For example after checkouting to that branch'],
        ['--name=issue_name_on_jira', 'Use this argument to provide a JIRA issue name. For example if the project short name is CNI, the issue name could be CNI-101']
      ].concat(super)
    end

    def run
      self
      start_working_on_issue(@issue_name)
    end

    private

    def start_working_on_issue(issue)
      jira_issue = @jira_api_client.fetch_jira_issue(issue)
      unless jira_issue
        ui.say("#{issue} doesn't exist on JIRA, skipping...")
        return
      end

      if jira_issue.status.in_progress?
        ui.say("#{issue} is already in progress...")
        return
      end

      proceed_option = ui.ask_with_answers("Are you going to work on #{issue}?\n", ["yes", "no"])
      return if proceed_option == "no"

      jira_issue_transitions = @jira_api_client.fetch_issue_transitions(jira_issue)
      unless jira_issue_transitions
        ui.error("#{issue} doesn't have any transitions...")
        return
      end
      to_in_progress_transition = jira_issue_transitions.select do |transition|
        transition.to_status.in_progress?
      end.first
      unless to_in_progress_transition
        ui.error("#{issue} doesn't have transition to 'In Progress' status...")
        return
      end
      jira_issue.make_transition(to_in_progress_transition.id)
      ui.inform("#{issue} now is 'In Progress' 💪")
    end

  end
end
