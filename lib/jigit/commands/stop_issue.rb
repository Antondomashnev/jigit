require "jigit/commands/issue"

module Jigit
  class StopIssueRunner < IssueRunner
    self.abstract_command = false
    self.summary = "Command to put the given JIRA issue to any state, but 'In Progress'"
    self.command = "stop"

    def run
      self
      jira_issue = @jira_api_client.fetch_jira_issue(@issue_name)
      new_status = new_status_for_issue(jira_issue)
      transition_finder = Jigit::JiraTransitionFinder(@jira_api_client.fetch_issue_transitions(jira_issue))
      to_new_status_transition = transition_finder.find_transition_to(new_status)
      unless to_new_status_transition
        ui.error("#{jira_issue} doesn't have transition to '#{new_status}' status...")
        return
      end
      jira_issue.make_transition(to_new_status_transition.id)
      ui.inform("#{jira_issue} now is '#{new_status}' 🎉")
    end

    private

    def new_status_for_issue(_jira_issue)
      question = "You've stopped working on '#{@issue_name}', to which status do you want to put it\n"
      new_status = ui.ask_with_answers(question, @jigitfile.other_statuses)
      new_status
    end
  end
end
