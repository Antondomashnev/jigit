require "jigit/jira_config"

describe Jigit::JiraConfig do
  context "when initialize" do
    context "when no user" do
      it "raises an error" do
        expect { Jigit::JiraConfig.new(nil, "1234567890", "my.jira.com") }.to raise_error("User name must not be nil")
      end
    end

    context "when no password" do
      it "raises an error" do
        expect { Jigit::JiraConfig.new("superman", nil, "my.jira.com") }.to raise_error("Password must not be nil")
      end
    end

    context "when no host" do
      it "raises an error" do
        expect { Jigit::JiraConfig.new("superman", "1234567890", nil) }.to raise_error("Host must not be nil")
      end
    end
  end
end
