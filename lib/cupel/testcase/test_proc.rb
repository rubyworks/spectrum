module Cupel

  class TestCase

    # Test procedure: a single test of a test case.
    #
    class TestProc

      # New unit test procedure.
      #
      def initialize(options={}, &procedure)
        @context   = options[:context]
        @label     = options[:label]
        @tags      = options[:tags] || []
        @skip      = options[:skip]
        @file      = options[:file]
        @line      = options[:line]

        @procedure = procedure
      end

      #
      # The parent testcase to which this test belongs.
      #
      attr :context

      #
      # Alias for `#context`.
      #
      alias :parent :context

      #
      # Description of test.
      #
      attr :label

      #
      # Symbol list of tags. Trailing element may be Hash
      # of `symbol => object`.
      #
      attr :tags

      #
      # Test procedure, in which test assertions should be made.
      #
      attr :procedure

      #
      # Rubytest uses `type` to describe the nature of a test object.
      #
      def type
        'test'
      end

      #
      # Whether to skip this test.
      #
      # @return [Boolean,String]
      #
      def skip? ; @skip ; end

      #
      # Set whether this test should be skipped of not.
      #
      # @param [Boolean,String] reason
      #   Reason to skip, or simple boolean flag.
      #
      def skip=(reason)
        @skip = reason
      end

      #
      # The unit under test, from the test's case.
      #
      def unit
        context.unit if context
      end

      #
      # Test description.
      #
      # @return [String]
      #
      def to_s
        label.to_s
      end

      #
      # Location of test definition.
      #
      def source_location
        [@file, @line]
      end

      #
      # Match test's label and/or tags.
      #
      # @param [String,Symbol,Regexp,Hash] match
      #   Pattern to match against.
      #
      # @return [Boolean]
      #
      def match?(match)
        case match
        when Symbol
          tags.include?(match)
        when Hash
          if Hash === tags.last
            tags.last.any?{ |k,v| match[k] == v }
          end
        else
          match === label
        end
      end

      #
      # Run this test in its scope: setup, the test, and the teardown,
      # which runs whether or not the test passes.
      #
      def call
        @scope.setup
        begin
          @scope.instance_eval(&procedure)
        ensure
          @scope.teardown
        end
      end

      #
      # Return a copy of the test bound to +scope+, an instance of its
      # test case.
      #
      def for(scope)
        test = dup
        test.instance_variable_set(:@scope, scope)
        test
      end

    end

  end

end
