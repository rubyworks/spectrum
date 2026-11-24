require_relative 'cupel/version'
require_relative 'cupel/world'

# Cupel is a library of test structures: the words that organize tests
# into cases, specifications or features. Each is loaded on its own.
#
#   require 'cupel/testcase'   # TestCase "..." do ... test "..." do
#   require 'cupel/spec'       # describe "..." do ... it "..." do
#   require 'cupel/feature'    # Feature "..." do ... Scenario "..." do
#
# The tests they build are run by Rubytest, and what a test asserts is
# left to an assertion library, such as Assay.
module Cupel
end

# The global test suite, which Rubytest runs.
$TEST_SUITE ||= []

# Leave Cupel's own lines out of the backtraces in test reports.
$RUBY_IGNORE_CALLERS ||= []
$RUBY_IGNORE_CALLERS << Regexp.new(Regexp.escape(File.join(__dir__, 'cupel')))
