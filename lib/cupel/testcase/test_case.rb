module Cupel

  # A test case is a collection of tests, which can be organized into
  # groups of contexts. Each test case, and each context, is a subclass
  # of TestCase, and its tests run in an instance of it.
  #
  class TestCase
    include World

    class << self

      # Brief description of the test case.
      attr :label

      # Symbol list of tags. Trailing element may be Hash
      # of `symbol => object`.
      attr :tags

      # Code unit that is subject of test case.
      attr :unit

      # List of tests and sub-cases.
      def tests
        @tests ||= []
      end

      # Set up a new test case.
      #
      def __set__(settings={}, &block)
        @label   = settings[:label]
        @tags    = settings[:tags]
        @skip    = settings[:skip]

        @unit    = calc_unit(@label)

        @tests   = []

        class_eval(&block)
      end

      #
      # The unit under test, taken from the label: a class or module, or
      # a method of the parent case's unit if the label names one, e.g.
      # `#join`.
      #
      def calc_unit(label)
        case label
        when Module, Class
          label
        when /^(\.|\#|\:\:)\w+/
          if Module === superclass.unit
            [superclass.unit, label].join('')
          else
            label
          end
        end
      end

      #
      # Add new test or sub-case.
      #
      # @param [Class<TestCase>,TestProc] test_object
      #   Test sub-case or procedure to add to this case.
      #
      def <<(test_object)
        tests << test_object
      end

      #
      # Is test case to be skipped?
      #
      # @return [Boolean,String]
      #   If +false+ or +nil+ if not skipped, otherwise
      #   +true+ or a string explain why to skip.
      #
      def skip?
        @skip
      end

      #
      # Set test case to be skipped.
      #
      # @param [Boolean,String] reason
      #   Set to +false+ or +nil+ if not skipped, otherwise
      #   +true+ or a string explain why to skip.
      #
      def skip=(reason)
        @skip = reason
      end

      #
      # Create a sub-case.
      #
      # @param [String] label
      #   The breif description of the test case.
      #
      # @param [Array<Symbol,Hash>] tags
      #   List of symbols with optional trailing `symbol=>object` hash.
      #   These can be used as a means of filtering tests.
      #
      def Context(label, *tags, &block)
        context = Class.new(self)
        context.__set__(
          :skip    => @_skip,
          :label   => label,
          :tags    => tags,
          &block
        )

        self << context unless equal?(Cupel::TestCase)

        context
      end

      alias :context :Context

      #
      # Create a test, or a parameterized test.
      #
      # A test whose block takes arguments is parameterized: each `ok`
      # that follows makes a test of it with the arguments given.
      #
      # A test without a block is one still to be written.
      #
      # @param [String] label
      #   The breif description of the test case.
      #
      # @param [Array<Symbol,Hash>] tags
      #   List of symbols with optional trailing `symbol=>object` hash.
      #   These can be used as a means of filtering tests.
      #
      def Test(label=nil, *tags, &procedure)
        location = caller_locations(1,1).first

        settings = {
          :context => self,
          :skip    => @_skip,
          :label   => label,
          :tags    => tags,
          :file    => location.path,
          :line    => location.lineno
        }

        procedure ||= proc{ raise NotImplementedError, "test not written" }

        if procedure.arity == 0
          test = TestProc.new(settings, &procedure)

          self << test

          @_test = nil

          return test
        else
          @_test = [settings, procedure]
        end
      end

      alias :test :Test

      #
      # Actualize a parameterized test.
      #
      def Ok(*args)
        raise ArgumentError, "no parameterized test to apply `ok` to" unless @_test

        settings, procedure = *@_test

        location = caller_locations(1,1).first
        settings = settings.merge(
          :label => "#{settings[:label]} (#{args.map{ |a| a.inspect }.join(', ')})",
          :file  => location.path,
          :line  => location.lineno
        )

        test = TestProc.new(settings) do
          instance_exec(*args, &procedure)
        end

        self << test

        return test
      end

      alias :ok :Ok

      #
      # Setup is used to set things up for each unit test.
      # The setup procedure is run before each unit.
      #
      # @param [String] label
      #   A brief description of what the setup procedure sets-up.
      #
      def Setup(label=nil, &proc)
        define_method(:setup, &proc)
        # if the setup is reset, then so should the teardown
        define_method(:teardown){}
      end

      alias :setup :Setup

      #
      # Teardown procedure is used to clean-up after each unit test.
      #
      def Teardown(&proc)
        define_method(:teardown, &proc)
      end

      alias :teardown :Teardown

      #
      # Mark tests or sub-cases to be skipped. If block is given, then
      # tests defined within the block are skipped. Without a block
      # all subsquent tests defined in a context will be skipped.
      #
      # @param [Boolean,String] reason
      #   Set to +false+ or +nil+ if not skipped, otherwise
      #   +true+ or a string explain why to skip.
      #
      # @example
      #   skip("awaiting new feature") do
      #     test "some test" do
      #       ...
      #     end
      #   end
      #
      # @example
      #   skip("not on jruby") if jruby?
      #   test "some test" do
      #     ...
      #   end
      #
      def Skip(reason=true, &block)
        if block
          previous, @_skip = @_skip, reason
          begin
            block.call
          ensure
            @_skip = previous
          end
        else
          @_skip = reason
        end
      end

      alias :skip :Skip

      #
      # Test case label.
      #
      # @return [String]
      #
      def to_s
        label ? label.to_s : super
      end

      alias :inspect :to_s

    end

    #
    # Iterate over each test and sub-case.
    #
    def each
      self.class.tests.each do |test_object|
        case test_object
        when Class #TestCase
          yield(test_object.new)
        when TestProc
          yield(test_object.for(self.class.new))
        end
      end
    end

    #
    # Number of tests and sub-cases.
    #
    # @return [Integer] size
    #
    def size
      self.class.tests.size
    end

    #
    # Is the test case to be skipped?
    #
    def skip?
      self.class.skip?
    end

    #
    # Rubytest uses `type` to describe the nature of a test object.
    #
    def type
      'TestCase'
    end

    #
    # The unit under test, if the test case names one.
    #
    def unit
      self.class.unit
    end

    #
    # Test case label.
    #
    # @return [String]
    #
    def to_s
      self.class.label.to_s
    end

    #
    # Dummy method for setup.
    #
    def setup
    end

    #
    # Dummy method for teardown.
    #
    def teardown
    end

  end

end
