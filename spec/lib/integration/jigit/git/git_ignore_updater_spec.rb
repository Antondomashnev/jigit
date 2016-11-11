require "jigit/git/git_ignore_updater"
require "fileutils"

describe Jigit::GitIgnoreUpdater do
  describe(".ignore") do
    after(:each) do
      FileUtils.rm_rf("spec/fixtures/git_ignore_updater")
    end

    context("when there is empty .gitignore") do
      before(:each) do
        FileUtils.mkdir_p("spec/fixtures/git_ignore_updater")
        FileUtils.touch("spec/fixtures/git_ignore_updater/.gitignore")
        @subject = Jigit::GitIgnoreUpdater.new("spec/fixtures/git_ignore_updater/.gitignore")
        @subject.ignore(".jigit")
      end

      it("ignores the given line") do
        actual_lines = []
        expected_lines = [".jigit\n"]
        File.foreach("spec/fixtures/git_ignore_updater/.gitignore") { |line| actual_lines << line }
        expect(actual_lines).to be == expected_lines
      end
    end

    context("when there is not empty .gitignore") do
      before(:each) do
        FileUtils.mkdir_p("spec/fixtures/git_ignore_updater")
        FileUtils.touch("spec/fixtures/git_ignore_updater/.gitignore")
        @subject = Jigit::GitIgnoreUpdater.new("spec/fixtures/git_ignore_updater/.gitignore")
        File.open("spec/fixtures/git_ignore_updater/.gitignore", "r+") do |f|
          f.puts(".DS_Store")
        end
        @subject.ignore(".jigit")
      end

      it("ignores the given line") do
        actual_lines = []
        expected_lines = [".DS_Store\n", ".jigit\n"]
        File.foreach("spec/fixtures/git_ignore_updater/.gitignore") { |line| actual_lines << line }
        expect(actual_lines).to be == expected_lines
      end
    end
  end
end
