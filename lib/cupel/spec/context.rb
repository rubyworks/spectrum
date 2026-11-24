module Cupel
  module Spec

    # This is the BDD form of a test case. It encapsulates a collection
    # of examples.
    #
    # This is the `describe` in your specs.
    #
    class Context

      #
      # The parent context in which this describe resides.
      #
      attr :parent

      #
      # A description of the describe clause.
      #
      attr :label

      #
      # A target class, if any.
      #
      attr :subject

      #
      # Array and/or metadata Hash of tags.
      #
      attr :tags

      #
      # List of examples and sub-specifications.
      #
      attr :specs

      #
      # The before and after hooks.
      #
      attr :hooks

      #
      # Skip critera.
      #
      # @return [Array<Array>] pairs of reason and Proc
      #
      attr :skips

      #
      # Omit criteria.
      #
      # @return [Array<Array>] pairs of reason and Proc
      #
      attr :omits

      #
      # DSL module for evaluating `describe` blocks.
      #
      attr :scope

      #
      # A context's subject, if it has one, is a class or module.
      #
      def initialize(settings={}, &block)
        @parent  = settings[:parent]
        @subject = settings[:subject]
        @label   = settings[:label]
        @tags    = settings[:tags] || []
        @skip    = settings[:skip]

        @hooks = Hooks.new
        @skips = []
        @omits = []

        @specs = []

        @scope = Scope.new(self)

        evaluate(&block)
      end

      #
      # Evalute a block of code in the context of the Context's scope.
      # When finished it applies `omits` and `skips` to the examples,
      # removing them and marking them to be skipped respectively.
      #
      def evaluate(&block)
        @scope.module_eval(&block) if block
        apply(omits, skips)
      end

      #
      # Apply omit and skip criteria to the examples of this context and
      # of the contexts within it.
      #
      def apply(omits, skips)
        specs.delete_if do |spec|
          Example === spec && omits.any?{ |reason, test| test.call(spec) }
        end

        specs.each do |spec|
          if Example === spec
            skips.each do |reason, test|
              spec.skip = reason if test.call(spec)
            end
          else
            spec.apply(omits, skips)
          end
        end
      end

      #
      # This context and those around it, outermost first.
      #
      def lineage
        parent ? parent.lineage + [self] : [self]
      end

      #
      # The scope that before-all and after-all hooks run in.
      #
      def it_scope
        @it_scope ||= Example::Scope.new(self)
      end

      #
      # Add `it` or sub-`describe` to group.
      #
      def <<(spec)
        @specs << spec
      end

      #
      # Iterate over each test and subcase.
      #
      def each(&block)
        specs.each(&block)
      end

      #
      # Run before-all and after-all advice around yielding to the
      # examples.
      #
      def call
        hooks.run(self, :before, :all, it_scope)
        begin
          yield
        ensure
          hooks.run(self, :after, :all, it_scope)
        end
      end

      #
      # Number of specs plus subcases.
      #
      def size
        specs.size
      end

      #
      # Rubytest uses `type` to describe the nature of a test object.
      #
      def type
        'describe'
      end

      #
      # Returns the subject/label as string.
      #
      def to_s
        label.to_s
      end

      alias :inspect :to_s

      #
      # Skip this group?
      #
      def skip?
        @skip
      end

      #
      #
      #
      def skip=(reason)
        @skip = reason
      end

      # The module a `describe` block is evaluated in. Its instance
      # methods, such as helpers and `let` values, are for the examples;
      # the methods below are the words of the specification.
      #
      class Scope < Module

        #
        # Setup new evaluation scope.
        #
        def initialize(group)
          super()

          @_group = group
          @_hooks = group.hooks
          @_skips = group.skips
          @_omits = group.omits

          if group.parent
            include(group.parent.scope)
          end
        end

        #
        # Create a new sub-specification.
        #
        def describe(topic, *tags, &block)
          settings = {}
          settings[:parent]  = @_group
          settings[:subject] = @_group.subject
          settings[:tags]    = tags

          if Module === topic
            settings[:subject] = topic
            settings[:label]   = topic.name
          else
            settings[:label]   = topic
          end

          group = Context.new(settings, &block)

          @_group.specs << group

          return group
        end

        alias_method :context, :describe

        #
        # Create an example behavior. Without a block, the example is
        # one still to be written.
        #
        # If tags or keys are given, so must a label.
        #
        def it(label=nil, *tags, &procedure)
          location = caller_locations(1,1).first

          settings = {
            :parent => @_group,
            :topic  => @_topic,
            :label  => label,
            :tags   => tags,
            :file   => location.path,
            :line   => location.lineno
          }

          spec = Example.new(settings, &procedure)

          @_group.specs << spec

          spec
        end

        alias_method :example, :it

        #
        # Define before procedure.
        #
        # @example
        #   describe '#puts' do
        #     it "gives standard output" do
        #       puts "Hello"
        #     end
        #
        #     before do
        #       $stdout = StringIO.new
        #     end
        #
        #     after do
        #       $stdout = STDOUT
        #     end
        #   end
        #
        # @param [Symbol] which
        #   Must be either `:all` or `:each`, the later being the default.
        #
        # @param [Array<Symbol>] tags
        #   List of match critera that must be matched
        #   against tags to trigger the before procedure.
        #
        def before(which=:each, *tags, &procedure)
          @_hooks.add(:before, which, *tags, &procedure)
        end

        #
        # Define an after procedure. See #before.
        #
        # @param [Symbol] which
        #   Must be either `:all` or `:each`, the later being the default.
        #
        # @param [Array<Symbol>] tags
        #   List of match critera that must be matched
        #   to trigger the after procedure.
        #
        def after(which=:each, *tags, &procedure)
          @_hooks.add(:after, which, *tags, &procedure)
        end

        #
        # Mark examples to be skipped: those matching the criteria, or
        # those the block returns true for, or all of them if neither is
        # given. It applies to the whole context and the contexts within
        # it, wherever in the context it is written.
        #
        # @example
        #   it "does something" do
        #     ...
        #   end
        #
        #   skip("not on jruby", /something/) if jruby?
        #
        def skip(reason=true, *criteria, &block)
          @_skips << [reason, criterion(criteria, &block)]
        end

        #
        # Mark examples to be omitted. Omitting an example is different
        # from skipping, in that a skipped example is still sent up to
        # the test harness, where as an omitted one is never added at all.
        #
        # @example
        #   it "does something" do
        #     ...
        #   end
        #
        #   omit(/something/) if jruby?
        #
        def omit(*criteria, &block)
          @_omits << [true, criterion(criteria, &block)]
        end

        #
        # Define a value for the examples, computed the first time an
        # example asks for it.
        #
        def let(name, &block)
          define_method(name) do
            @_let.fetch(name){ |k| @_let[k] = instance_eval(&block) }
          end
        end

        #
        # Like #let, but computed before each example whether or not it
        # asks for it.
        #
        def let!(name, &block)
          let(name, &block)
          before { __send__(name) }
        end

        #
        # Define the subject of the examples.
        #
        def subject(topic=nil, &block)
          @_topic = topic
          define_method(:subject) do
            return @_subject if defined?(@_subject)
            @_subject = instance_eval(&block)
          end
        end

        #
        # Subject-oriented example: the block runs in the result of
        # calling the method, or chain of methods, on the subject.
        #
        def its(invocation, &block)
          it(invocation.to_s) do
            calls = invocation.to_s.split('.')
            calls.inject(subject){ |s,m| s.__send__(m) }.instance_eval(&block)
          end
        end

        #
        # Bring in a set of shared examples.
        #
        def it_behaves_like(label)
          proc = Cupel::Spec.shared_examples[label]
          raise ArgumentError, "no shared examples for #{label.inspect}" unless proc
          module_eval(&proc)
        end

        alias_method :include_examples, :it_behaves_like

      private

        # A procedure that tells whether an example meets the criteria.
        def criterion(criteria, &block)
          if block
            block
          elsif criteria.empty?
            lambda{ |spec| true }
          else
            lambda{ |spec| criteria.any?{ |c| spec.match?(c) } }
          end
        end

      end

    end

  end
end
