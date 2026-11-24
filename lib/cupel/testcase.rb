require_relative '../cupel'
require_relative 'testcase/test_proc'
require_relative 'testcase/test_case'

module Cupel

  class TestCase

    # The words the test case structure adds to the toplevel.
    module DSL
      #
      # Define a general test case.
      #
      def test_case(label, *tags, &block)
        testcase = Cupel::TestCase.context(label, *tags, &block)
        $TEST_SUITE << testcase.new
        testcase
      end

      alias :TestCase :test_case
      alias :testcase :test_case
    end

  end

end

extend Cupel::TestCase::DSL
