require 'jira-ruby'

module Jigit
  class JiraHelper
    def initialize(config, jira_client = nil)
      raise "Config must not be nil to use JiraHelper" unless config
      @config = config
      @jira_client = jira_client
    end

    def jira_client
      options = {
            :username => @config.user,
            :password => @config.password,
            :site     => "https://#{@config.host}",
            :context_path => '',
            :auth_type => :basic
          }
      @jira_client ||= JIRA::Client.new(options)
    end

    def fetch_jira_issue_status(issue_name)
      return nil unless issue_name
      issue_status = jira_client.Issue.jql("key = #{issue_name}", {fields: %w(status)}).first
      issue_status
    end
  end
end
