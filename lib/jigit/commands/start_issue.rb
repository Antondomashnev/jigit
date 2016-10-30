require "jigit/commands/issue"

module Jigit
  class StartIssueRunner < IssueRunner
    self.abstract_command = false
    self.summary = "Command to put the given JIRA issue to 'In Progress' state"
    self.command = "start"

    def initialize(argv)
      @issue_name = argv.option("name")
      super
    end

    def validate!
      super
      help!("Please specify JIRA issue. It must not be nil.") unless @issue_name
    end

    def self.options
      [
        ["--name=issue_name_on_jira", "Use this argument to provide a JIRA issue name. For example if the project short name is CNI, the issue name could be CNI-101"]
      ].concat(super)
    end

    def run
      self
      return unless want_to_start_working_on_issue?

      jira_issue = @jira_api_client.fetch_jira_issue(@issue_name)
      return unless could_start_working_on_issue?(jira_issue)

      transition_finder = Jigit::JiraTransitionFinder(@jira_api_client.fetch_issue_transitions(jira_issue))
      to_in_progress_transition = transition_finder.find_transition_to_in_progress
      unless to_in_progress_transition
        ui.error("#{issue} doesn't have transition to 'In Progress' status...")
        return
      end

      jira_issue.make_transition(to_in_progress_transition.id)
      ui.inform("#{issue} now is 'In Progress' 💪")
    end

    private

    def want_to_start_working_on_issue?
      proceed_option = ui.ask_with_answers("Are you going to work on #{issue}?\n", ["yes", "no"])
      proceed_option == "no"
    end

    def could_start_working_on_issue?(jira_issue)
      unless jira_issue
        ui.say("#{issue} doesn't exist on JIRA, skipping...")
        return false
      end

      if jira_issue.status.in_progress?
        ui.say("#{issue} is already in progress...")
        return false
      end
      return true
    end
  end
end
