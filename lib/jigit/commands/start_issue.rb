require "jigit/commands/issue"
require "jigit/jira/jira_transition_finder"

module Jigit
  class StartIssueRunner < IssueRunner
    self.abstract_command = false
    self.summary = "Command to put the given JIRA issue to 'In Progress' state"
    self.command = "start"

    def run
      self
      begin
        jira_issue = @jira_api_client.fetch_jira_issue(@issue_name)
        return unless could_start_working_on_issue?(jira_issue, @issue_name)
        return unless want_to_start_working_on_issue?(jira_issue)
        put_issue_to_in_progress(jira_issue)
      rescue Jigit::JiraInvalidIssueKeyError
        ui.say "#{@issue_name} doesn't exist on JIRA, skipping..."
      rescue Jigit::JiraAPIClientError => exception
        ui.error "Error while executing issue start command: #{exception.message}"
      rescue Jigit::NetworkError => exception
        ui.error "Error while executing issue start command: #{exception.message}"
      end
    end

    private

    def put_issue_to_in_progress(jira_issue)
      transition_finder = Jigit::JiraTransitionFinder.new(@jira_api_client.fetch_issue_transitions(jira_issue))
      to_in_progress_transition = transition_finder.find_transition_to(@jigitfile.in_progress_status)
      unless to_in_progress_transition
        ui.error("#{issue.key} doesn't have transition to '#{@jigitfile.in_progress_status}' status...")
        return
      end

      jira_issue.make_transition(to_in_progress_transition.id)
      ui.inform("#{@issue_name} now is '#{@jigitfile.in_progress_status}' 💪")
    end

    def want_to_start_working_on_issue?(jira_issue)
      proceed_option = ui.ask_with_answers("Are you going to work on #{jira_issue.key}?\n", ["yes", "no"])
      proceed_option == "yes"
    end

    def could_start_working_on_issue?(jira_issue, issue_name)
      unless jira_issue
        ui.say("#{issue_name} doesn't exist on JIRA, skipping...")
        return false
      end

      if jira_issue.status.name == @jigitfile.in_progress_status
        ui.say("#{jira_issue.key} is already #{@jigitfile.in_progress_status}...")
        return false
      end
      return true
    end
  end
end
