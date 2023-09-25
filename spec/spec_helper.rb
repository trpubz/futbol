require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  add_filter "spec/"
  add_filter "./data/"
  add_filter "./lib/runner.rb"
end

require "csv"
require "./lib/stat_tracker"
require "./lib/stats"
