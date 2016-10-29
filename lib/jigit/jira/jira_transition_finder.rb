require "jigit/jira/resources/jira_transition"

module Jigit
  class JiraTransitionFinder
    def initialize(transitions)
      @transitions = transitions
    end

    def find_transition_to_in_progress
      return nil unless @transitions
      @transitions.select do |transition|
        transition.to_status.in_progress?
      end.first
    end
  end
end
