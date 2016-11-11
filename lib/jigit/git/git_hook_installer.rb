require "fileutils"

module Jigit
  # Command to setup the git hook for jigit
  class GitHookInstaller
    def initialize(git_hooks_folder = nil, git_path = nil)
      @git_hooks_folder = git_hooks_folder ? git_hooks_folder : default_git_hooks_folder
      @git_path = git_path ? git_path : default_git_path
      @is_git_hook_file_new = false
    end

    def install(hook)
      @git_hook_name = hook.name
      @git_hook_file_path = "#{@git_hooks_folder}/#{@git_hook_name}"

      ensure_git_hook_file_exists
      ensure_git_hook_file_is_executable
      write_hook_lines(hook.hook_lines)
    end

    private

    def ensure_git_hook_file_exists
      @git_hook_file_path = File.realpath(@git_hook_file_path) if File.symlink?(@git_hook_file_path)
      return if File.exist?(@git_hook_file_path)

      raise "Git folder is not found at '#{@git_path}'" unless Dir.exist?(@git_path)

      FileUtils.mkdir_p(@git_hooks_folder)
      @git_hook_file_path = "#{@git_hooks_folder}/#{@git_hook_name}"
      FileUtils.touch(@git_hook_file_path)
      FileUtils.chmod("u=xwr", @git_hook_file_path)
      @is_git_hook_file_new = true
    end

    def ensure_git_hook_file_is_executable
      raise "git hook file at '#{@git_hook_file_path}' is not executable by the effective user id of this process" unless File.executable?(@git_hook_file_path)
    end

    def write_hook_lines(hook_lines)
      File.open(@git_hook_file_path, @is_git_hook_file_new ? "r+" : "a") do |f|
        hook_lines.each do |line|
          f.puts(line)
        end
      end
    end

    def git_hook_file_path
      "#{default_git_hooks_folder}/#{@git_hook_name}"
    end

    def default_git_path
      ".git"
    end

    def default_git_hooks_folder
      "#{default_git_path}/hooks"
    end
  end
end
