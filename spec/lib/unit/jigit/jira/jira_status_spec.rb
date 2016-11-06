require "jigit/jira/resources/jira_status"

describe Jigit::JiraStatus do
  let(:config) { object_double(Jigit::JiraConfig) }
  let(:site_url) { "http://foo:bar@localhost:2990" }
  let(:jira_client) do
    basic_client = JIRA::Client.new({ username: "foo", password: "bar", auth_type: :basic, use_ssl: false })
    basic_client
  end

  describe(".id") do
    let(:base_status) do
      base_status = JIRA::Resource::Status.new(jira_client, attrs: {
        "id" => "1",
        "self" => "http://localhost:2990/jira/rest/api/2/status/1"
      })
      base_status
    end

    it("returns id of the base status") do
      expect(Jigit::JiraStatus.new(base_status).id).to be == "1"
    end
  end

  describe(".name") do
    let(:base_status) do
      base_status = JIRA::Resource::Status.new(jira_client, attrs: {
        "id" => "1",
        "self" => "http://localhost:2990/jira/rest/api/2/status/1",
        "name" => "In Progress"
      })
      base_status
    end

    it("returns name of the base status") do
      expect(Jigit::JiraStatus.new(base_status).name).to be == "In Progress"
    end
  end

  describe(".new") do
    context("when without base status") do
      it("raises an error") do
        expect { Jigit::JiraStatus.new(nil) }.to raise_error("Can not initialize JiraStatus without jira-ruby status")
      end
    end

    context("when with base status") do
      let(:base_status) do
        base_status = JIRA::Resource::Status.new(jira_client, attrs: {
          "id" => "1",
          "self" => "http://localhost:2990/jira/rest/api/2/status/1"
        })
        base_status
      end

      it("assigns the base issue") do
        status = Jigit::JiraStatus.new(base_status)
        expect(status.jira_ruby_status).to be(base_status)
      end
    end
  end
end
