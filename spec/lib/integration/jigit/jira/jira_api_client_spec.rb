require "jigit/jira/jira_api_client"
require "webmock/rspec"

describe Jigit::JiraAPIClient do
  let(:config) { object_double(Jigit::JiraConfig) }
  let(:site_url) { "http://foo:bar@localhost:2990" }
  let(:jira_client) do
    basic_client = JIRA::Client.new({ username: "foo", password: "bar", auth_type: :basic, use_ssl: false })
    basic_client
  end

  describe("fetch_issue_transitions") do
    let(:jira_issue) do
      base_issue = JIRA::Resource::Issue.new(jira_client, attrs: {
        "id" => "10002",
        "self" => "#{site_url}/jira/rest/api/2/issue/10002",
        "fields" => {
          "comment" => { "comments" => [] }
        }
      })
      issue = Jigit::JiraIssue.new(base_issue)
      issue
    end

    context("when there is HTTP error") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/issue/10002/transitions?expand=transitions.fields").
          to_return(status: 405, body: "<html><body>Some HTML</body></html>")
      end

      it("returns nil") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect(jira_api_client.fetch_issue_transitions(jira_issue)).to be_nil
      end
    end

    context("when there is no transitions") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/issue/10002/transitions?expand=transitions.fields").
          to_return(status: 301, body: "{\"errorMessages\":[\"Transitions Do Not Exist\"],\"errors\":{}}")
      end

      it("returns nil") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect(jira_api_client.fetch_issue_transitions(jira_issue)).to be_nil
      end
    end

    context("when there are transitions") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/issue/10002/transitions?expand=transitions.fields").
          to_return(status: 200, body: get_mock_response("issue_1002_transitions.json"))
      end

      it("returns correct amount of transitions") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        fetched_transitions = jira_api_client.fetch_issue_transitions(jira_issue)
        expect(fetched_transitions.count).to be == 4
      end

      it("returns wrapped jira transitions") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        fetched_transitions = jira_api_client.fetch_issue_transitions(jira_issue)
        expect(fetched_transitions).to all(be_instance_of(Jigit::JiraTransition))
      end
    end
  end

  describe("fetch_jira_issue") do
    let(:issue_name) { "ADT-1" }

    context("when there is HTTP error") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/search?jql=key%20=%20ADT-1").
          to_return(status: 405, body: "<html><body>Some HTML</body></html>")
      end

      it("returns nil") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect(jira_api_client.fetch_jira_issue(issue_name)).to be_nil
      end
    end

    context("when there is no issue") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/search?jql=key%20=%20ADT-1").
          to_return(status: 301, body: "{\"errorMessages\":[\"Issue Does Not Exist\"],\"errors\":{}}")
      end

      it("returns nil") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect(jira_api_client.fetch_jira_issue(issue_name)).to be_nil
      end
    end

    context("when there is issue") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/search?jql=key%20=%20ADT-1").
          to_return(status: 200, body: get_mock_response("issue.json"))
      end

      it("returns wrapped jira issue") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        fetched_issue = jira_api_client.fetch_jira_issue(issue_name)
        expect(fetched_issue).to be_instance_of(Jigit::JiraIssue)
      end
    end
  end
end
