$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

# Needs to be required and started before danger
require "simplecov"
require 'simplecov-json'
SimpleCov.start do
  add_filter "/spec/"
end
SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter

def get_mock_response(file, value_if_file_not_found = false)
  file.sub!("?", "_") # we have to replace this character on Windows machine
  File.read(File.join(File.dirname(__FILE__), "mock_responses/", file))
rescue Errno::ENOENT => e
  raise e if value_if_file_not_found == false
  value_if_file_not_found
end
