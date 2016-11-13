require "jigit/commands/issue"
require "jigit/jira/jira_transition_finder"

module Jigit
  class StopIssueRunner < IssueRunner
    self.abstract_command = false
    self.summary = "Command to put the given JIRA issue to any state, but 'In Progress'"
    self.command = "stop"

    def run
      self
      begin
        jira_issue = @jira_api_client.fetch_jira_issue(@issue_name)
        return unless issue_exists?(jira_issue)
        new_status = ask_for_new_status_for_issue
        put_issue_to_status(jira_issue, new_status)
      rescue Jigit::JiraInvalidIssueKeyError
        ui.say "#{@issue_name} doesn't exist on JIRA, skipping..."
      rescue Jigit::NetworkError => exception
        ui.error "Error while executing issue stop command: #{exception.message}"
      rescue Jigit::JiraAPIClientError => exception
        ui.error "Error while executing issue stop command: #{exception.message}"
      end
    end

    private

    def put_issue_to_status(jira_issue, new_status)
      transition_finder = Jigit::JiraTransitionFinder.new(@jira_api_client.fetch_issue_transitions(jira_issue))
      to_new_status_transition = transition_finder.find_transition_to(new_status)
      unless to_new_status_transition
        ui.error("#{jira_issue.key} doesn't have transition to '#{new_status}' status...")
        return
      end
      jira_issue.make_transition(to_new_status_transition.id)
      ui.inform("#{jira_issue.key} now is '#{new_status}' 🎉")
    end

    def issue_exists?(jira_issue)
      unless jira_issue
        ui.say("#{@issue_name} doesn't exist on JIRA, skipping...")
        return false
      end
      return true
    end

    def ask_for_new_status_for_issue
      question = "You've stopped working on '#{@issue_name}', to which status do you want to put it\n"
      new_status = ui.ask_with_answers(question, @jigitfile.other_statuses, true)
      new_status
    end
  end
end
