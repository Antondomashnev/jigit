require "jigit/commands/issue"

module Jigit
  class StopIssueRunner < IssueRunner
    self.abstract_command = false
    self.summary = "Command to put the given JIRA issue to any state, but 'In Progress'"
    self.command = "stop"

    def run
      self
    end
  end
end
