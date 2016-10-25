require 'jigit/jira/resources/jira_status'

module Jigit
  class JiraIssue
    attr_reader :jira_ruby_issue

    def initialize(jira_ruby_issue)
      raise "Can not initialize JiraIssue without jira-ruby issue" unless jira_ruby_issue
      @jira_ruby_issue = jira_ruby_issue
    end

    def status
      Jigit::JiraStatus.new(self.jira_ruby_issue.status)
    end

    def assignee_name
      @jira_ruby_issue.assignee.name
    end

    def update_status(status_id)
      raise "status_id must not be nil" unless status_id
      @jira_ruby_issue.save({"fields"=>{"status"=>{"id"=>status_id}}})
    end
  end
end
