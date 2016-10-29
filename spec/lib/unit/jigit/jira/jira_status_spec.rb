require "jigit/jira/resources/jira_status"

describe Jigit::JiraStatus do
  let(:config) { object_double(Jigit::JiraConfig) }
  let(:site_url) { "http://foo:bar@localhost:2990" }
  let(:jira_client) {
    basic_client = JIRA::Client.new({ :username => 'foo', :password => 'bar', :auth_type => :basic, :use_ssl => false })
    basic_client
  }

  describe(".id") do
    let(:base_status) {
      base_status = JIRA::Resource::Status.new(jira_client, :attrs => {
        'id' => '1',
        'self' => "http://localhost:2990/jira/rest/api/2/status/1"
      })
      base_status
    }

    it("returns id of the base status") do
      expect(Jigit::JiraStatus.new(base_status).id).to be == '1'
    end
  end

  describe(".name") do
    let(:base_status) {
      base_status = JIRA::Resource::Status.new(jira_client, :attrs => {
        'id' => '1',
        'self' => "http://localhost:2990/jira/rest/api/2/status/1",
        'name' => "In Progress"
      })
      base_status
    }

    it("returns name of the base status") do
      expect(Jigit::JiraStatus.new(base_status).name).to be == 'In Progress'
    end
  end

  describe(".in_progress?") do
    context("when name is In Progress") do
      let(:base_status) {
        base_status = JIRA::Resource::Status.new(jira_client, :attrs => {
          'id' => '1',
          'self' => "http://localhost:2990/jira/rest/api/2/status/1",
          'name' => "In Progress"
        })
        base_status
      }

      it("returns true") do
        expect(Jigit::JiraStatus.new(base_status).in_progress?).to be(true)
      end
    end

    context("when name is not In Progress") do
      let(:base_status) {
        base_status = JIRA::Resource::Status.new(jira_client, :attrs => {
          'id' => '1',
          'self' => "http://localhost:2990/jira/rest/api/2/status/1",
          'name' => "Whatever"
        })
        base_status
      }

      it("returns false") do
        expect(Jigit::JiraStatus.new(base_status).in_progress?).to be(false)
      end
    end
  end

  describe(".new") do
    context("when without base status") do
      it("raises an error") do
        expect { Jigit::JiraStatus.new(nil) }.to raise_error("Can not initialize JiraStatus without jira-ruby status")
      end
    end

    context("when with base status") do
      let(:base_status) {
        base_status = JIRA::Resource::Status.new(jira_client, :attrs => {
          'id' => '1',
          'self' => "http://localhost:2990/jira/rest/api/2/status/1"
        })
        base_status
      }

      it("assigns the base issue") do
        status = Jigit::JiraStatus.new(base_status)
        expect(status.jira_ruby_status).to be(base_status)
      end
    end
  end
end
