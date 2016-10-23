require "jigit/commands/runner"
require "jigit/jira/jira_helper"
require "jigit/jira/jira_config"

module Jigit
  class IssueRunner < Runner
    self.abstract_command = false
    self.summary = "Any commands on Jira issue"
    self.command = "issue"

    def initialize(argv)
      @action = argv.shift_argument
      @issue_name = argv.option('name')
      @jira_config = Jigit::JiraConfig.new("antondomashnev+jira1@gmail.com", "Anton2104", "antondomashnevjira1.atlassian.net") # Jigit::JiraConfig.current_jira_config
      @jira_helper = Jigit::JiraHelper.new(@jira_config) if @jira_config
      super
    end

    def validate!
      super
      if @action && !%w(stop start).include?(@action)
        help! "`#{@action}' is not a valid action."
      end
      help! "Please setup jira config using `jigit init` before using issue command." unless @jira_config
      help! "Please specify JIRA issue. It must not be nil." unless @issue_name
    end

    def self.options
      [
        ['stop', 'Use this argument if you want to stop working on the feature. For example after checkouting to another branch'],
        ['start', 'Use this argument if you want to start working on the feature. For example after checkouting to that branch'],
        ['--name=issue_name_on_jira', 'Use this argument to provide a JIRA issue name. For example if the project short name is CNI, the issue name could be CNI-101']
      ].concat(super)
    end

    def run
      self
      start_working_on_issue(@issue_name)
    end

    private

    def start_working_on_issue(issue)
       puts @jira_helper.fetch_jira_issue_status(issue)
    end

  end
end
