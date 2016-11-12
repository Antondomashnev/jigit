require "jira-ruby"
require "jigit/jira/resources/jira_issue"
require "jigit/jira/resources/jira_status"
require "jigit/jira/resources/jira_transition"
require "jigit/jira/jira_api_client_error"

module Jigit
  class JiraAPIClient
    def initialize(config, jira_client = nil)
      raise "Config must not be nil to use JiraHelper" unless config
      @config = config
      @jira_client = jira_client
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

    def validate_api?
      serverinfo = jira_client.ServerInfo.all
      return !serverinfo.nil?
    rescue SocketError => exception
      raise Jigit::JiraAPIClientError.new("Can not fetch Jira server info: #{exception.message}")
    rescue JIRA::HTTPError => exception
      raise Jigit::JiraAPIClientError.new("Can not fetch Jira server info: #{exception.response.body}")
    end

    def fetch_issue_transitions(issue)
      raise "Can not fetch a JIRA issue's transitions without issue name" unless issue.jira_ruby_issue
      begin
        transitions = jira_client.Transition.all(issue: issue.jira_ruby_issue)
        return nil unless transitions
        transitions.map do |transition|
          Jigit::JiraTransition.new(transition)
        end
      rescue SocketError => exception
        raise Jigit::JiraAPIClientError.new("Can not fetch JIRA issue transitions: #{exception.message}")
      rescue JIRA::HTTPError => exception
        raise Jigit::JiraAPIClientError.new("Can not fetch JIRA issue transitions: #{exception.response.body}")
      end
    end

    def fetch_jira_issue(issue_name)
      raise "Can not fetch a JIRA issue without issue name" unless issue_name
      begin
        issue = jira_client.Issue.jql("key = #{issue_name}").first
        return nil unless issue
        Jigit::JiraIssue.new(issue)
      rescue SocketError => exception
        raise Jigit::JiraAPIClientError.new("Can not fetch a JIRA issue: #{exception.message}")
      rescue JIRA::HTTPError => exception
        raise Jigit::JiraAPIClientError.new("Can not fetch a JIRA issue: #{exception.response.body}")
      end
    end

    def fetch_jira_statuses
      statuses = jira_client.Status.all
      return nil unless statuses
      statuses.map do |status|
        Jigit::JiraStatus.new(status)
      end
    rescue SocketError => exception
      raise Jigit::JiraAPIClientError.new("Can not fetch a JIRA statuses: #{exception.message}")
    rescue JIRA::HTTPError => exception
      raise Jigit::JiraAPIClientError.new("Can not fetch a JIRA statuses: #{exception.response.body}")
    end
  end
end
