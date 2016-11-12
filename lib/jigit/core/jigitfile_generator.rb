require "jigit/core/jigitfile_constants"
require "fileutils"
require "yaml"

module Jigit
  class JigitfileGenerator
    def initialize(path = nil)
      @path = path ? path : ".jigit"
      @jigitfile_hash = {}
    end

    def write_in_progress_status_name(name)
      raise "In progress status name can not be empty" if name.nil? || name.empty?
      @jigitfile_hash[JigitfileConstants.in_progress_status] = name
    end

    def write_other_statuses(other_statuses)
      raise "All statuses must be string" if other_statuses.select { |status| !status.kind_of?(String) }.count > 0
      @jigitfile_hash[JigitfileConstants.other_statuses] = other_statuses.map.with_index { |status, i| "#{i + 1}. #{status}" }
    end

    def save
      FileUtils.mkdir_p(@path)
      File.open("#{@path}/Jigitfile.yml", "w") do |file|
        file.write(@jigitfile_hash.to_yaml)
      end
    end
  end
end
