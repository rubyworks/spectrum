module Spectrum
  class Feature

    # A step of a scenario: one `Given`, `When` or `Then` line. To
    # Rubytest each step is a test.
    #
    class Step

      #
      def initialize(scenario, label, settings={})
        @scenario = scenario
        @label    = label
        @type     = settings[:type]
        @file     = settings[:file]
        @line     = settings[:line]
      end

      # The type of step (:given, :when or :then).
      attr :type

      # The scenario to which this step belongs.
      attr :scenario

      # Label of test.
      attr :label

      #
      def to_s
        "#{type.to_s.capitalize} #{label}"
      end

      # Location of the step in its scenario.
      def source_location
        [@file, @line]
      end

      #
      def to_proc
        lambda{ call }
      end

      #
      def call
        scenario.run(self)
      end

    end

  end
end
