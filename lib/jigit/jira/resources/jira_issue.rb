require "jigit/jira/resources/jira_status"
require "jigit/jira/resources/jira_transition"

module Jigit
  class JiraIssue
    attr_reader :jira_ruby_issue

    def initialize(jira_ruby_issue)
      raise "Can not initialize JiraIssue without jira-ruby issue" unless jira_ruby_issue
      @jira_ruby_issue = jira_ruby_issue
    end

    def status
      Jigit::JiraStatus.new(@jira_ruby_issue.status)
    end

    def assignee_name
      @jira_ruby_issue.assignee.name
    end

    def make_transition(transition_id)
      raise "status_id must not be nil" unless transition_id
      transition = @jira_ruby_issue.transitions.build
      transition.save!("transition" => { "id" => transition_id })
    end
  end
end
