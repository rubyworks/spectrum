module Cupel
  module Spec

    # The before and after procedures of a context.
    #
    class Hooks

      #
      def initialize
        @hooks_all  = {:before=>[], :after=>[]}
        @hooks_each = {:before=>[], :after=>[]}
      end

      #
      def add(tense, range, *tags, &proc)
        case range
        when :all
          raise ArgumentError, "tagged #{tense}-all advice is useless" unless tags.empty?
          @hooks_all[tense]  << Hook.new(tense, range, *tags, &proc)
        when :each
          @hooks_each[tense] << Hook.new(tense, range, *tags, &proc)
        else
          raise ArgumentError, "range must be :all or :each"
        end
      end

      #
      # Run the hooks. After-hooks run in the reverse of the order they
      # were defined.
      #
      def run(target, tense, range, scope)
        case range
        when :all
          list = hooks_all[tense]
        when :each
          list = hooks_each[tense].select{ |hook| hook.match?(target) }
        else
          raise ArgumentError, "range must be :all or :each"
        end
        list = list.reverse if tense == :after
        list.each do |hook|
          scope.instance_eval(&hook)
        end
      end

    protected

      #
      attr :hooks_all

      #
      attr :hooks_each

      # Encapsulates a hook procedure along with it's match tags.
      #
      class Hook
        def initialize(tense, scope, *tags, &proc)
          @tense = tense
          @scope = scope
          @tags  = tags
          @proc  = proc
        end

        #
        # Check for matching labels or tags for each advice.
        #
        def match?(it)
          return true if @tags.empty?
          @tags.any? do |t|
            it.match?(t)
          end
        end

        #
        def to_proc
          @proc
        end
      end

    end

  end
end
