require "jigit/jira/jira_config"

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

  context "when store config" do
    before do
      @config = Jigit::JiraConfig.new("superman", "1234567890", "my.jira.com")
    end

    it "saves name in ENV" do
      allow(ENV).to receive(:[]).with("JIGIT_JIRA_CONFIG_USER").and_return(nil)
      Jigit::JiraConfig.store_jira_config(@config)
    end

    it "saves password in ENV" do
      allow(ENV).to receive(:[]).with("JIGIT_JIRA_CONFIG_PASSWORD").and_return(nil)
      Jigit::JiraConfig.store_jira_config(@config)
    end

    it "saves host in ENV" do
      allow(ENV).to receive(:[]).with("JIGIT_JIRA_CONFIG_HOST").and_return(nil)
      Jigit::JiraConfig.store_jira_config(@config)
    end
  end

  context "when get current jira config" do
    context "when there is config stored" do
      before do
        allow(ENV).to receive(:[]).with("JIGIT_JIRA_CONFIG_USER").and_return("superman")
        allow(ENV).to receive(:[]).with("JIGIT_JIRA_CONFIG_PASSWORD").and_return("1234567890")
        allow(ENV).to receive(:[]).with("JIGIT_JIRA_CONFIG_HOST").and_return("my.jira.com")
      end

      it "returns valid config" do
        config = Jigit::JiraConfig.current_jira_config
        expect(config.user).to eq("superman")
        expect(config.password).to eq("1234567890")
        expect(config.host).to eq("my.jira.com")
      end
    end

    context "when there is no config stored" do
      before do
        expect(ENV).to receive(:[]).with("JIGIT_JIRA_CONFIG_USER").and_return(nil)
        expect(ENV).to receive(:[]).with("JIGIT_JIRA_CONFIG_PASSWORD").and_return(nil)
        expect(ENV).to receive(:[]).with("JIGIT_JIRA_CONFIG_HOST").and_return(nil)
      end

      it "returns nil" do
        expect(Jigit::JiraConfig.current_jira_config).to be_nil
      end
    end
  end
end
