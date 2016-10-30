require "jigit/commands/issue"

module Jigit
  class StopIssueRunner < IssueRunner
    self.abstract_command = false
    self.summary = "Command to put the given JIRA issue to any state, but 'In Progress'"
    self.command = "stop"

    def initialize(argv)
      @issue_name = argv.option("name")
      super
    end

    def validate!
      super
      help!("Please specify JIRA issue. It must not be nil.") unless @issue_name
    end

    def self.options
      [
        ["--name=issue_name_on_jira", "Use this argument to provide a JIRA issue name. For example if the project short name is CNI, the issue name could be CNI-101"]
      ].concat(super)
    end

    def run
      self
      @jira_api_client.fetch_jira_statuses
    end
  end
end
