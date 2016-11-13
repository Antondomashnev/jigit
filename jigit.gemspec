# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jigit/version"

Gem::Specification.new do |spec|
  spec.name          = "jigit"
  spec.version       = Jigit::VERSION
  spec.authors       = ["Anton Domashnev"]
  spec.email         = ["antondomashnev@gmail.com"]
  spec.description   = Jigit::DESCRIPTION
  spec.summary       = "Keep the status of the JIRA issue always in sync with your local git"
  spec.homepage      = "https://github.com/Antondomashnev/nabokov"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_runtime_dependency "ruby-keychain", "~> 0.3"
  spec.add_runtime_dependency "claide", "~> 1.0"
  spec.add_runtime_dependency "cork", "~> 0.1"
  spec.add_runtime_dependency "jira-ruby", "~> 1.0"

  spec.add_development_dependency "webmock", "~> 1.18", ">= 1.18.0"
  spec.add_development_dependency "rubocop", "~> 0.42"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 3.0", ">= 3.0.0"
  spec.add_development_dependency "rake", "~> 10.3", ">= 10.3.2"
  spec.add_development_dependency "simplecov", "~> 0.12.0"
end
