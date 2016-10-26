require 'jira-ruby'
require 'jigit/jira/resources/jira_issue'
require 'jigit/jira/resources/jira_status'
require 'jigit/jira/resources/jira_transition'

module Jigit
  class JiraHelper
    def initialize(config, jira_client = nil)
      raise "Config must not be nil to use JiraHelper" unless config
      @config = config
      @jira_client = jira_client
    end

    def jira_client
      return @jira_client if @jira_client
      options = {
            :username => @config.user,
            :password => @config.password,
            :site     => "https://#{@config.host}",
            :context_path => '',
            :auth_type => :basic
          }
      @jira_client ||= JIRA::Client.new(options)
    end

    def fetch_all_statuses
      statuses = jira_client.Status.all
      return nil unless statuses
      statuses.map do |status|
        Jigit::JiraStatus.new(status)
      end
    end

    def fetch_issue_transitions(issue)
      raise "Can not fetch a JIRA issue's transitions without issue name" unless issue.jira_ruby_issue
      transitions = jira_client.Transition.all(:issue => issue.jira_ruby_issue)
      return nil unless transitions
      transitions.map do |transition|
        Jigit::JiraTransition.new(transition)
      end
    end

    def fetch_jira_issue(issue_name)
      raise "Can not fetch a JIRA issue without issue name" unless issue_name
      issue = jira_client.Issue.jql("key = #{issue_name}").first
      return nil unless issue
      Jigit::JiraIssue.new(issue)
    end

    def update_jira_issue_status(jira_issue, new_status_id)
      raise "Can not update nil jira issue" unless jira_issue
      raise "Can not update issue with unknown status" unless new_status_id

    end
  end
end
