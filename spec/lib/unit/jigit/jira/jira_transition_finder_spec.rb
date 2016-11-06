require "jigit/jira/jira_transition_finder"

describe Jigit::JiraTransitionFinder do
  describe ".initialize" do
    context "when transitions are nil" do
      it "returns an object" do
        expect(Jigit::JiraTransitionFinder.new(nil)).to_not be_nil
      end
    end

    context "when there are no transitions" do
      it "returns an object" do
        expect(Jigit::JiraTransitionFinder.new([])).to_not be_nil
      end
    end

    context "when there are transitions" do
      it "returns an object" do
        expect(Jigit::JiraTransitionFinder.new([double(Jigit::JiraTransition)])).to_not be_nil
      end
    end
  end

  describe ".find_transition_to_in_progress" do
    context "when there is transition with to_status == in progress" do
      before(:each) do
        transition1 = double(Jigit::JiraTransition)
        status1 = double(Jigit::JiraStatus)
        allow(status1).to receive(:name).and_return("Done")
        allow(transition1).to receive(:to_status).and_return(status1)

        @transition2 = double(Jigit::JiraTransition)
        status2 = double(Jigit::JiraStatus)
        allow(status2).to receive(:name).and_return("In Progress")
        allow(@transition2).to receive(:to_status).and_return(status2)

        transition3 = double(Jigit::JiraTransition)
        status3 = double(Jigit::JiraStatus)
        allow(status3).to receive(:name).and_return("In Review")
        allow(transition3).to receive(:to_status).and_return(status3)

        @jira_transition_finder = Jigit::JiraTransitionFinder.new([transition1, @transition2, transition3])
      end

      it "finds a transition" do
        expect(@jira_transition_finder.find_transition_to("In Progress")).to be == @transition2
      end
    end

    context "when there is no transition with to_status == in progress" do
      before(:each) do
        transition1 = double(Jigit::JiraTransition)
        status1 = double(Jigit::JiraStatus)
        allow(status1).to receive(:name).and_return("Done")
        allow(transition1).to receive(:to_status).and_return(status1)

        transition2 = double(Jigit::JiraTransition)
        status2 = double(Jigit::JiraStatus)
        allow(status2).to receive(:name).and_return("In Review")
        allow(transition2).to receive(:to_status).and_return(status2)

        @jira_transition_finder = Jigit::JiraTransitionFinder.new([transition1, transition2])
      end

      it "doesn't find a transition" do
        expect(@jira_transition_finder.find_transition_to("In Progress")).to be_nil
      end
    end
  end
end
