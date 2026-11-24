module Cupel

  # Features contain scenarios, and the step definitions the scenarios
  # are run by: the _given_, _when_ and _then_ procedures.
  #
  class Feature

    # Brief description of the feature.
    attr :label

    # The descriptive details of the feature, defined using
    # the `To`, `As` and `We` methods.
    attr :story

    # List of scenarios.
    attr :scenarios

    # The step definitions.
    attr :advice

    # Module the feature's block is evaluated in. Methods defined
    # there are helpers for the step procedures.
    attr :scope

    #
    def initialize(settings={}, &block)
      @label     = settings[:label]

      @advice    = Advice.new
      @story     = []
      @scenarios = []

      @scope = Scope.new(self, &block)
    end

    # Convenience method for accessing advice, aka step definitions.
    def [](key)
      @advice[key]
    end

    # Iterate over each scenario.
    def each(&block)
      scenarios.each(&block)
    end

    # Number of scenarios.
    def size
      scenarios.size
    end

    # The type is "Feature". This is used by Rubytest in test output.
    def type
      'Feature'
    end

    #
    def to_s
      (["#{label}"] + story).join("\n")
    end

    #
    # Take on the step definitions of a featurette.
    #
    def update(mixin)
      [:given, :when, :then].each do |type|
        @advice[type].update(mixin[type] || {})
      end
    end

    # The module a feature's block is evaluated in.
    #
    class Scope < Module

      #
      def initialize(feature, &block)
        super(&nil)
        @_feature = feature
        @_skip    = false
        module_eval(&block) if block
      end

      #
      def To(description)
        @_feature.story << "To " + description
      end

      alias :to :To

      #
      def As(description)
        @_feature.story << "As " + description
      end

      alias :as :As

      #
      def We(description)
        @_feature.story << "We " + description
      end

      alias :we :We

      #
      def I(description)
        @_feature.story << "I " + description
      end

      alias :i :I

      #
      # Define a Scenario.
      #
      def Scenario(label, &procedure)
        scenario = Scenario.new(
          @_feature,
          :skip  => @_skip,
          :label => label,
          &procedure
        )
        @_feature.scenarios << scenario
        @_skip = false
        scenario
      end

      alias :scenario :Scenario

      # Given ...
      #
      # @param [String] description
      #   A brief description of the _given_ criteria.
      #
      def Given(description, &procedure)
        @_feature[:given][description] = procedure
      end

      alias :given :Given

      # When ...
      #
      # @param [String] description
      #   A brief description of the _when_ criteria.
      #
      def When(description, &procedure)
        @_feature[:when][description] = procedure
      end

      alias :wence :When

      # Then ...
      #
      # @param [String] description
      #   A brief description of the _then_ criteria.
      #
      def Then(description, &procedure)
        @_feature[:then][description] = procedure
      end

      alias :hence :Then

      # Skip the next scenario when running feature.
      #
      #  skip "for some reason"
      #  Scenario "blah blah blah" do
      #    # ...
      #  end
      #
      def skip(reason=true)
        @_skip = reason
      end

      #
      # Access to underlying feature instance.
      #
      def _feature
        @_feature
      end

      #
      # Include module and if a Featurette, also update Feature instance.
      #
      def include(*mixins)
        mixins.each do |mixin|
          @_feature.update(mixin) if Featurette === mixin
        end
        super
      end

    end

  end

end
