module Jigit
  class GitHook
    def self.hook_lines
      raise "GitHook subclass must specify the actual hook lines"
    end

    def self.name
      raise "GitHook subclass must specify the actual name"
    end
  end
end
