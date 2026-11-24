require_relative 'spectrum/version'
require_relative 'spectrum/world'

# Spectrum is a library of test structures: the words that organize tests
# into cases, specifications or features. Each is loaded on its own.
#
#   require 'spectrum/testcase'   # TestCase "..." do ... test "..." do
#   require 'spectrum/describe'   # describe "..." do ... it "..." do
#   require 'spectrum/feature'    # Feature "..." do ... Scenario "..." do
#
# The tests they build are run by Rubytest, and what a test asserts is
# left to an assertion library, such as Assay.
module Spectrum
end

# The global test suite, which Rubytest runs.
$TEST_SUITE ||= []

# Leave Spectrum's own lines out of the backtraces in test reports.
$RUBY_IGNORE_CALLERS ||= []
$RUBY_IGNORE_CALLERS << Regexp.new(Regexp.escape(File.join(__dir__, 'spectrum')))
