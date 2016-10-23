module Jigit
  class JiraConfig
    attr_accessor :user
    attr_accessor :password
    attr_accessor :host

    def initialize(user, password, host)
      raise "User name must not be nil" unless user
      raise "Password must not be nil" unless password
      raise "Host must not be nil" unless host
      self.user = user
      self.password = password
      self.host = host
    end

    def self.store_store_config(config)
      ENV['JIGIT_JIRA_CONFIG_USER'] = config.user
      ENV['JIGIT_JIRA_CONFIG_PASSWORD'] = config.password
      ENV['JIGIT_JIRA_CONFIG_HOST'] = config.host
    end

    def self.current_jira_config
      user = ENV['JIGIT_JIRA_CONFIG_USER']
      password = ENV['JIGIT_JIRA_CONFIG_PASSWORD']
      host = ENV['JIGIT_JIRA_CONFIG_HOST']
      if user && password && host
        return JiraConfig.new(user, password, host)
      else
        return nil
      end
    end
  end
end
