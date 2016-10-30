require "jira-ruby"
require "jigit/jira/resources/jira_issue"
require "jigit/jira/resources/jira_status"
require "jigit/jira/resources/jira_transition"

module Jigit
  class JiraAPIClient
    def initialize(config, jira_client = nil, informator = nil)
      raise "Config must not be nil to use JiraHelper" unless config
      @config = config
      @jira_client = jira_client
      @informator = informator
    end

    def jira_client
      return @jira_client if @jira_client
      options = {
            username: @config.user,
            password: @config.password,
            site: "https://#{@config.host}",
            context_path: "",
            auth_type: :basic
          }
      @jira_client ||= JIRA::Client.new(options)
    end

    def fetch_issue_transitions(issue)
      raise "Can not fetch a JIRA issue's transitions without issue name" unless issue.jira_ruby_issue
      begin
        transitions = jira_client.Transition.all(issue: issue.jira_ruby_issue)
        return nil unless transitions
        transitions.map do |transition|
          Jigit::JiraTransition.new(transition)
        end
      rescue JIRA::HTTPError => exception
        @informator.error("Can not fetch Jira issue transitions: #{exception.response.body}") if @informator
        return nil
      end
    end

    def fetch_jira_issue(issue_name)
      raise "Can not fetch a JIRA issue without issue name" unless issue_name
      begin
        issue = jira_client.Issue.jql("key = #{issue_name}").first
        return nil unless issue
        Jigit::JiraIssue.new(issue)
      rescue JIRA::HTTPError => exception
        @informator.error("Can not fetch a JIRA issue: #{exception.response.body}") if @informator
        return nil
      end
    end

    def fetch_jira_statuses
      statuses = jira_client.Status.all
      return nil unless statuses
      statuses.map do |status|
        Jigit::JiraStatus.new(status)
      end
    rescue JIRA::HTTPError => exception
      @informator.error("Can not fetch a JIRA statuses: #{exception.response.body}") if @informator
      return nil
    end
  end
end
