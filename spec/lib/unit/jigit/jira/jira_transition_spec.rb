require "jigit/jira/resources/jira_transition"

describe Jigit::JiraTransition do
  let(:config) { object_double(Jigit::JiraConfig) }
  let(:site_url) { "http://foo:bar@localhost:2990" }
  let(:jira_client) {
    basic_client = JIRA::Client.new({ :username => 'foo', :password => 'bar', :auth_type => :basic, :use_ssl => false })
    basic_client
  }

  describe(".to_status") do
    let(:base_transition) {
      base_transition = JIRA::Resource::Transition.new(jira_client, :attrs => {
        'id' => '52',
        'name' => 'Review',
        'to' => {
          'id' => '1003'
        }
      }, :issue_id => '10014')
      base_transition
    }

    it("returns the wrapped jira status") do
      expect(Jigit::JiraTransition.new(base_transition).to_status).to be_instance_of(Jigit::JiraStatus)
    end
  end

  describe(".id") do
    let(:base_transition) {
      base_transition = JIRA::Resource::Transition.new(jira_client, :attrs => {
        'id' => '52',
        'name' => 'Review'
      }, :issue_id => '10014')
      base_transition
    }

    it("returns id of the base transition") do
      expect(Jigit::JiraTransition.new(base_transition).id).to be == "52"
    end
  end

  describe(".new") do
    context("when without base transition") do
      it("raises an error") do
        expect { Jigit::JiraTransition.new(nil) }.to raise_error("Can not initialize transition without jira-ruby transition")
      end
    end

    context("when with base transition") do
      let(:base_transition) {
        base_transition = JIRA::Resource::Transition.new(jira_client, :attrs => {
          'id' => '52',
          'name' => 'Review'
        }, :issue_id => '10014')
        base_transition
      }

      it("assigns the base transition") do
        transition = Jigit::JiraTransition.new(base_transition)
        expect(transition.jira_ruby_transition).to be(base_transition)
      end
    end
  end
end
