require "jigit/git_hooks/git_hook_installer"
require "fileutils"

describe Jigit::GitHookInstaller do
  describe(".install") do
    after(:each) do
      FileUtils.rm_rf("spec/fixtures/git_hook_installer")
    end

    context("when there is already git hook file") do
      before(:each) do
        FileUtils.mkdir_p("spec/fixtures/git_hook_installer/.git/hooks")
        FileUtils.touch("spec/fixtures/git_hook_installer/.git/hooks/my_hook")
        FileUtils.chmod("u=xwr", "spec/fixtures/git_hook_installer/.git/hooks/my_hook")
        File.open("spec/fixtures/git_hook_installer/.git/hooks/my_hook", "r+") do |f|
          f.puts("First line")
        end

        @subject = Jigit::GitHookInstaller.new("my_hook",
                                               "spec/fixtures/git_hook_installer/.git/hooks",
                                               "spec/fixtures/git_hook_installer/.git")
        @subject.install(["Second line", "Third line"])
      end

      it("appends the given lines into git hook file") do
        actual_lines = []
        expected_lines = ["First line\n", "Second line\n", "Third line\n"]
        File.foreach("spec/fixtures/git_hook_installer/.git/hooks/my_hook") { |line| actual_lines << line }
        expect(actual_lines).to be == expected_lines
      end
    end

    context("when there is no git hook file") do
      before(:each) do
        FileUtils.mkdir_p("spec/fixtures/git_hook_installer/.git")

        @subject = Jigit::GitHookInstaller.new("my_hook",
                                               "spec/fixtures/git_hook_installer/.git/hooks",
                                               "spec/fixtures/git_hook_installer/.git")
        @subject.install(["First line", "Second line"])
      end

      it("creates the hook file") do
        expect(File.exist?("spec/fixtures/git_hook_installer/.git/hooks/my_hook")).to be(true)
      end

      it("writes the given lines into git hook file") do
        actual_lines = []
        expected_lines = ["First line\n", "Second line\n"]
        File.foreach("spec/fixtures/git_hook_installer/.git/hooks/my_hook") { |line| actual_lines << line }
        expect(expected_lines).to be == actual_lines
      end

      it("ensures that the git hook file executable") do
        expect(File.executable?("spec/fixtures/git_hook_installer/.git/hooks/my_hook")).to be(true)
      end
    end
  end
end
