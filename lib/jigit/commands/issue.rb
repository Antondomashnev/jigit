require "jigit/commands/runner"
require "jigit/jira/jira_api_client"
require "jigit/jira/jira_config"

module Jigit
  class IssueRunner < Runner
    self.abstract_command = true
    self.summary = "Abstract command for commands related to JIRA issue"
    self.command = "issue"

    def initialize(argv)
      super
      @jira_config = Jigit::JiraConfig.new("antondomashnev+jira1@gmail.com", "Anton2104", "antondomashnevjira1.atlassian.net") # Jigit::JiraConfig.current_jira_config
      @jira_api_client = Jigit::JiraAPIClient.new(@jira_config, nil, ui) if @jira_config
    end

    def validate!
      super
      help!("Please setup jira config using `jigit init` before using issue command.") unless @jira_config
    end

    def self.options
      []
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
