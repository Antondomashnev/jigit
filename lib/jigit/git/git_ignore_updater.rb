module Jigit
  class GitIgnoreUpdater
    def initialize(git_ignore_path = nil)
      @gitignore_path = git_ignore_path ? git_ignore_path : default_gitignore_path
      raise "Gitignore file at #{@gitignore_path} is not found" unless @gitignore_path
    end

    def ignore(line_to_ignore)
      File.open(@gitignore_path, "a") do |f|
        f.puts(line_to_ignore)
      end
    end

    private

    def default_gitignore_path
      ".gitignore"
    end
  end
end
