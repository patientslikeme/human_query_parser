$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'
require 'pry'

require 'human_query_parser'

if ENV['BUILD_NUMBER']
  Minitest::Reporters.use!(
    [MiniTest::Reporters::DefaultReporter.new, MiniTest::Reporters::JUnitReporter.new('test/reports')],
    ENV,
    Minitest.backtrace_filter,
  )
else
  Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new, ENV, Minitest.backtrace_filter)
end
