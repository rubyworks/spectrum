module Spectrum
  class Feature

    # A scenario is a list of steps, run in order in a scope of their
    # own, so one scenario's state is not seen by the next.
    #
    class Scenario

      #
      def initialize(feature, settings={}, &block)
        @feature = feature
        @label   = settings[:label]
        @skip    = settings[:skip]
        @steps   = []

        Builder.new(self, &block)
      end

      # Parent feature.
      attr :feature

      # Description of scenario.
      attr :label

      # List scenario steps.
      attr :steps

      # The object the scenario's step definitions run in. It has the
      # helper methods of the feature and of Spectrum::World.
      def scope
        @scope ||= (
          scope = Object.new
          scope.extend(World)
          scope.extend(feature.scope)
          scope
        )
      end

      # Skip this scenario from runs.
      #
      # @return [Boolean,String] reason for skipping
      def skip?
        @skip
      end

      # Scenario steps must be run in order.
      def ordered?
        true
      end

      # Iterate over steps.
      def each(&block)
        @steps.each(&block)
      end

      # Number of steps.
      def size
        @steps.size
      end

      # The type is "Scenario". This is used by Rubytest in test output.
      def type
        "Scenario"
      end

      # Provided the scenario label.
      def to_s
        @label.to_s
      end

      #
      # Start from a clean scope, then yield to the steps.
      #
      def call
        @scope   = nil
        @blocked = false
        yield
      end

      #
      # Run a step in the context of this scenario, by the first step
      # definition of its type whose description matches.
      #
      # A step without a definition is one still to be written. Once a
      # step has failed, or wasn't defined, those after it are not run,
      # since they depend on it; they are reported as still to be done.
      #
      def run(step)
        if @blocked
          raise NotImplementedError, "not run, because an earlier step did not pass"
        end

        procedure, match = definition(step)

        unless procedure
          @blocked = true
          raise NotImplementedError, "no definition for step: #{step}"
        end

        begin
          scope.instance_exec(*match[1..-1], &procedure)
        rescue Exception
          @blocked = true
          raise
        end
      end

      #
      # Find the definition of a step.
      #
      # @return [Array] the procedure and the MatchData, or nil if there
      #   is none
      #
      def definition(step)
        feature.advice[step.type].each do |mask, procedure|
          if match = match_regexp(mask).match(step.label)
            return procedure, match
          end
        end
        nil
      end

      #
      # Convert a description into a regular expression. Text within
      # parentheses, e.g. `(\d+)`, is kept as regular expression, and
      # what it matches is passed to the step's procedure. The rest is
      # matched literally, save that case and the amount of whitespace
      # don't matter. The whole of the step's description has to match.
      #
      # To use a regular expression, but leave the resulting match out of
      # the arguments use `?:`, e.g. `(?:\d+)`.
      #
      def match_regexp(str)
        return str if Regexp === str
        str = str.split(/(\(.*?\))(?!\))/).map{ |x|
          x =~ /\A\((.*)\)\Z/ ? "(#{$1})" : Regexp.escape(x)
        }.join
        str = str.gsub(/(\\\s)+/, '\s+')
        Regexp.new('\A' + str + '\z', Regexp::IGNORECASE)
      end

      # Evaluates a scenario's block, collecting its steps.
      #
      class Builder

        #
        def initialize(scenario, &block)
          @scenario = scenario
          instance_eval(&block) if block
        end

        # Given ...
        #
        # @param [String] label
        #   A matching description of the _given_ procedure.
        #
        def Given(label)
          step(:given, label, caller_locations(1,1).first)
        end

        alias :given :Given

        # When ...
        #
        # @param [String] label
        #   A matching description of the _when_ procedure.
        #
        def When(label)
          step(:when, label, caller_locations(1,1).first)
        end

        alias :wence :When

        # Then ...
        #
        # @param [String] label
        #   A matching description of the _then_ procedure.
        #
        def Then(label)
          step(:then, label, caller_locations(1,1).first)
        end

        alias :hence :Then

        # And ..., a further step of the same type as the one before.
        #
        def And(label)
          type = @scenario.steps.empty? ? :given : @scenario.steps.last.type
          step(type, label, caller_locations(1,1).first)
        end

      private

        def step(type, label, location)
          @scenario.steps << Step.new(@scenario, label, :type=>type, :file=>location.path, :line=>location.lineno)
        end

      end

    end

  end
end
