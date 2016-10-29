require "rubygems"
require "bundler/gem_tasks"
require "rubocop/rake_task"
require "rspec/core/rake_task"

Dir.glob("tasks/*.rake").each { |r| import r }

begin
  RSpec::Core::RakeTask.new(:specs)
rescue LoadError
  puts "Please use `bundle exec` to get all the rake commands"
end

task default: [:prepare, :spec, :rubocop]

desc "Prepare and run rspec tests"
task :prepare do
  rsa_key = File.expand_path("rsakey.pem")
  unless File.exist?(rsa_key)
    raise "rsakey.pem does not exist, tests will fail.  Run `r` first"
  end
end

desc "Run jigit's spec tests"
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ["--color", "--format", "doc"]
end

desc "Run RuboCop on the lib/specs directory"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = Dir.glob(["lib/**/*.rb", "spec/**/*.rb"]) - Dir.glob(["spec/fixtures/**/*"])
end
