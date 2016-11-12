require "yaml"
require "jigit/core/jigitfile_constants"

module Jigit
  class Jigitfile
    # @return [String] The status which represens In Progress state
    attr_accessor :in_progress_status
    # @return [Array] The other possible statuses
    attr_accessor :other_statuses
    # @return [String] JIRA server host
    attr_accessor :host

    def initialize(path)
      raise "Path is a required parameter" if path.nil?
      raise "Couldn't find Jigitfile file at '#{path}'" unless File.exist?(path)
      jigitfile = File.read(path)
      yaml_hash = read_data_from_yaml_file(jigitfile, path)
      self.in_progress_status = yaml_hash[JigitfileConstants.in_progress_status]
      self.other_statuses = yaml_hash[JigitfileConstants.other_statuses]
      self.host = yaml_hash[JigitfileConstants.host]
    end

    private

    def read_data_from_yaml_file(yaml_file, path)
      YAML.load(yaml_file)
    rescue Psych::SyntaxError
      raise "File at '#{path}' doesn't have a legit YAML syntax"
    end
  end
end
