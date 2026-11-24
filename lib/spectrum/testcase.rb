require_relative '../spectrum'
require_relative 'testcase/test_proc'
require_relative 'testcase/test_case'

module Spectrum

  class TestCase

    # The words the test case structure adds to the toplevel.
    module DSL
      #
      # Define a general test case.
      #
      def test_case(label, *tags, &block)
        testcase = Spectrum::TestCase.context(label, *tags, &block)
        $TEST_SUITE << testcase.new
        testcase
      end

      alias :TestCase :test_case
      alias :testcase :test_case
    end

  end

end

extend Spectrum::TestCase::DSL
