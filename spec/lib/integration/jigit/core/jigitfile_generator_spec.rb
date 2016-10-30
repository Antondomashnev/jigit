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
      generator.save
    end

    it("writes prepopulated hash into yaml file") do
      expected_lines = ["---\n", "in_progress_status: In Progress\n", "other_statuses:\n", "- To Do\n", "- In Review\n", "- Done\n"]
      actual_lines = []
      File.foreach("spec/fixtures/Jigitfile.yml") do |line|
        actual_lines << line
      end
      expect(expected_lines).to be == actual_lines
    end
  end
end
