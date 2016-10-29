require "jigit/jira/resources/jira_issue"

describe Jigit::JiraIssue do
  let(:config) { object_double(Jigit::JiraConfig) }
  let(:site_url) { "http://foo:bar@localhost:2990" }
  let(:jira_client) do
    basic_client = JIRA::Client.new({ username: "foo", password: "bar", auth_type: :basic, use_ssl: false })
    basic_client
  end

  describe(".status") do
    let(:issue) do
      base_issue = JIRA::Resource::Issue.new(jira_client, attrs: {
        "id" => "10002",
        "self" => "http://localhost:2990/jira/rest/api/2/issue/10002",
        "fields" => {
          "status" => {
                        "self" => "http://localhost:2990/jira/rest/api/2/status/1",
                        "description" => "The issue is open and ready for the assignee to start work on it.",
                        "name" => "Open",
                        "id" => "1"
                      }
        }
      })
      issue = Jigit::JiraIssue.new(base_issue)
      issue
    end

    it("returns jigit status") do
      expect(issue.status).to be_instance_of(Jigit::JiraStatus)
    end
  end

  describe(".assignee_name") do
    let(:issue) do
      base_issue = JIRA::Resource::Issue.new(jira_client, attrs: {
        "id" => "10002",
        "self" => "http://localhost:2990/jira/rest/api/2/issue/10002",
        "fields" => {
          "assignee" => {
                        "self" => "http://localhost:2990/jira/rest/api/2/user?username=admin",
                        "name" => "admin",
                        "emailAddress" => "admin@example.com"
                      }
        }
      })
      issue = Jigit::JiraIssue.new(base_issue)
      issue
    end

    it("returns assignee name") do
      expect(issue.assignee_name).to be == "admin"
    end
  end

  describe(".new") do
    context("when without base issue") do
      it("raises and error") do
        expect { Jigit::JiraIssue.new(nil) }.to raise_error("Can not initialize JiraIssue without jira-ruby issue")
      end
    end

    context("when with base issue") do
      let(:base_issue) do
        base_issue = JIRA::Resource::Issue.new(jira_client, attrs: {
          "id" => "10002",
          "self" => "http://localhost:2990/jira/rest/api/2/issue/10002"
        })
        base_issue
      end

      it("assigns the base issue") do
        issue = Jigit::JiraIssue.new(base_issue)
        expect(issue.jira_ruby_issue).to be(base_issue)
      end
    end
  end
end
