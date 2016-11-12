require "jigit/commands/runner"
require "jigit/jira/jira_api_client"
require "jigit/jira/jira_config"
require "jigit/core/jigitfile"
require "jigit/helpers/keychain_storage"

module Jigit
  class IssueRunner < Runner
    self.abstract_command = true
    self.summary = "Abstract command for commands related to JIRA issue"
    self.command = "issue"

    def initialize(argv)
      super
      jigitfile = argv.option("jigitfile")
      unless jigitfile
        jigitfile = try_to_find_jigitfile_path
        raise "--jigitfile is a required parameter and could not be nil" if jigitfile.nil?
      end
      @jigitfile = Jigit::Jigitfile.new(jigitfile)
      @issue_name = argv.option("name")
      @jira_config = Jigit::KeychainStorage.new.load(jigitfile.host)
      @jira_api_client = Jigit::JiraAPIClient.new(@jira_config, nil) if @jira_config
    end

    def validate!
      super
      help!("Please setup jira config using `jigit init` before using issue command.") unless @jira_config
      help!("Please setup jigitfile using `jigit init` before using issue command.") unless @jigitfile
    end

    def self.options
      [
        ["--name=issue_name_on_jira", "Use this argument to provide a JIRA issue name. For example if the project short name is CNI, the issue name could be CNI-101"],
        ["--jigitfile=path_to_jigit_file", "Use this argument to provide a path to Jigitfile, if nil will be used a default path under the './jigit/' folder"]
      ].concat(super)
    end

    def run
      self
    end

    private

    def try_to_find_jigitfile_path
      pwd_jigitfile_yaml = Pathname.pwd + ".jigit/Jigitfile.yaml"
      jigitfile = pwd_jigitfile_yaml if File.exist?(pwd_jigitfile_yaml)
      return jigitfile unless jigitfile.nil?
      pwd_jigitfile_yml = Pathname.pwd + ".jigit/Jigitfile.yml"
      jigitfile = pwd_jigitfile_yml if File.exist?(pwd_jigitfile_yml)
      return jigitfile unless jigitfile.nil?
      return nil
    end
  end
end
