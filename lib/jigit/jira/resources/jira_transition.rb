module Jigit
  class JiraTransition
    attr_reader :jira_ruby_transition

    def initialize(jira_ruby_transition)
      raise "Can not initialize transition without jira_ruby_transition" unless jira_ruby_transition
      @jira_ruby_transition = jira_ruby_transition
    end

    def id
      @jira_ruby_transition.id
    end

    def to_status
      Jigit::JiraStatus.new(@jira_ruby_transition.to)
    end
  end
end
