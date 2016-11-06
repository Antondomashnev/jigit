require "jigit/jira/resources/jira_transition"

module Jigit
  class JiraTransitionFinder
    def initialize(transitions)
      @transitions = transitions
    end

    def find_transition_to(status_name)
      return nil unless @transitions
      @transitions.select do |transition|
        transition.to_status.name == status_name
      end.first
    end
  end
end
