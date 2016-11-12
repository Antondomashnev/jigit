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
  end
end
