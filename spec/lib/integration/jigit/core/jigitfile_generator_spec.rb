require "jigit/core/jigitfile_generator"
require "fileutils"

describe Jigit::JigitfileGenerator do
  after(:each) do
    FileUtils.rm_rf("spec/fixtures/Jigitfile.yml")
  end

  describe(".save") do
    before(:each) do
      generator = Jigit::JigitfileGenerator.new("spec/fixtures/")
      generator.write_in_progress_status_name("In Progress")
      generator.write_other_statuses(["To Do", "In Review", "Done"])
      generator.write_jira_host("myhost.atlassian.net")
      generator.save
    end

    it("writes prepopulated hash into yaml file") do
      expected_lines = ["---\n", "in_progress_status: In Progress\n", "other_statuses:\n", "- 1. To Do\n", "- 2. In Review\n", "- 3. Done\n", "host: myhost.atlassian.net\n"]
      actual_lines = []
      File.foreach("spec/fixtures/Jigitfile.yml") do |line|
        actual_lines << line
      end
      expect(expected_lines).to be == actual_lines
    end
  end
end
