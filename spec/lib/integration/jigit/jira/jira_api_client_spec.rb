require "jigit/jira/jira_api_client"
require "webmock/rspec"

describe Jigit::JiraAPIClient do
  let(:config) { object_double(Jigit::JiraConfig) }
  let(:site_url) { "http://foo:bar@localhost:2990" }
  let(:jira_client) {
    basic_client = JIRA::Client.new({ :username => 'foo', :password => 'bar', :auth_type => :basic, :use_ssl => false })
    basic_client
  }

  describe("fetch_jira_issue") do
    let(:issue_name) { "ADT-1" }

    context("when there is HTTP error") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/search?jql=key%20=%20ADT-1").
                    to_return(:status => 405, :body => "<html><body>Some HTML</body></html>")
      end

      it("returns nil") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect(jira_api_client.fetch_jira_issue(issue_name)).to be_nil
      end
    end

    context("when there is no issue") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/search?jql=key%20=%20ADT-1").
                    to_return(:status => 301, :body => "{\"errorMessages\":[\"Issue Does Not Exist\"],\"errors\":{}}")
      end

      it("returns nil") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        expect(jira_api_client.fetch_jira_issue(issue_name)).to be_nil
      end
    end

    context("when there is issue") do
      before do
        stub_request(:get, site_url + "/jira/rest/api/2/search?jql=key%20=%20ADT-1").
                    to_return(:status => 200, :body => get_mock_response('issue.json'))
      end

      it("returns wrapped jira issue") do
        jira_api_client = Jigit::JiraAPIClient.new(config, jira_client)
        fetched_issue = jira_api_client.fetch_jira_issue(issue_name)
        expect(fetched_issue).to be_truthy
      end
    end
  end



end
