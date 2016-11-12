require "jigit/jira/jira_api_client"
require "webmock/rspec"

describe Jigit::JiraAPIClient do
  let(:config) { object_double(Jigit::JiraConfig) }
  let(:site_url) { "http://foo:bar@localhost:2990" }
  let(:jira_client) do
    basic_client = JIRA::Client.new({ username: "foo", password: "bar", auth_type: :basic, use_ssl: false })
    basic_client
  end

  describe("fetch_jira_statuses") do
    context("when there is HTTP error") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/status").
          to_return(status: 405, body: "<html><body>Some HTML</body></html>")
      end

      it("raises an error") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect { jira_api_client.fetch_jira_statuses }.to raise_error "Can not fetch a JIRA statuses: <html><body>Some HTML</body></html>"
      end
    end

    context("when there is no statuses") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/status").
          to_return(status: 301, body: "{\"errorMessages\":[\"Statuses Do Not Exist\"],\"errors\":{}}")
      end

      it("returns nil") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect { jira_api_client.fetch_jira_statuses }.to raise_error "Can not fetch a JIRA statuses: {\"errorMessages\":[\"Statuses Do Not Exist\"],\"errors\":{}}"
      end
    end

    context("when there are statuses") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/status").
          to_return(status: 200, body: get_mock_response("statuses.json"))
      end

      it("returns correct amount of statuses") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        fetched_statuses = jira_api_client.fetch_jira_statuses
        expect(fetched_statuses.count).to be == 5
      end

      it("returns wrapped jira statuses") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        fetched_statuses = jira_api_client.fetch_jira_statuses
        expect(fetched_statuses).to all(be_instance_of(Jigit::JiraStatus))
      end
    end
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

      it("raises an error") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect { jira_api_client.fetch_issue_transitions(jira_issue) }.to raise_error "Can not fetch JIRA issue transitions: <html><body>Some HTML</body></html>"
      end
    end

    context("when there is no transitions") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/issue/10002/transitions?expand=transitions.fields").
          to_return(status: 301, body: "{\"errorMessages\":[\"Transitions Do Not Exist\"],\"errors\":{}}")
      end

      it("raises as error") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect { jira_api_client.fetch_issue_transitions(jira_issue) }.to raise_error "Can not fetch JIRA issue transitions: {\"errorMessages\":[\"Transitions Do Not Exist\"],\"errors\":{}}"
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

      it("raises an error") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect { jira_api_client.fetch_jira_issue(issue_name) }.to raise_error "Can not fetch a JIRA issue: <html><body>Some HTML</body></html>"
      end
    end

    context("when there is no issue") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/search?jql=key%20=%20ADT-1").
          to_return(status: 301, body: "{\"errorMessages\":[\"Issue Does Not Exist\"],\"errors\":{}}")
      end

      it("raises an error") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect { jira_api_client.fetch_jira_issue(issue_name) }.to raise_error "Can not fetch a JIRA issue: {\"errorMessages\":[\"Issue Does Not Exist\"],\"errors\":{}}"
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
