require "jigit/commands/issue"

module Jigit
  class StartIssueRunner < IssueRunner
    self.abstract_command = false
    self.summary = "Command to put the given JIRA issue to 'In Progress' state"
    self.command = "start"

    def run
      self
      return unless want_to_start_working_on_issue?

      jira_issue = @jira_api_client.fetch_jira_issue(@issue_name)
      return unless could_start_working_on_issue?(jira_issue)

      transition_finder = Jigit::JiraTransitionFinder(@jira_api_client.fetch_issue_transitions(jira_issue))
      to_in_progress_transition = transition_finder.find_transition_to(@jigitfile.in_progress_status)
      unless to_in_progress_transition
        ui.error("#{issue} doesn't have transition to '#{@jigitfile.in_progress_status}' status...")
        return
      end

      jira_issue.make_transition(to_in_progress_transition.id)
      ui.inform("#{issue} now is '#{@jigitfile.in_progress_status}' 💪")
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

      if jira_issue.status.name == @jigitfile.in_progress_status
        ui.say("#{issue} is already #{@jigitfile.in_progress_status}...")
        return false
      end
      return true
    end
  end
end
