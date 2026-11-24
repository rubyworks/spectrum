require_relative '../spectrum'

module Spectrum

  # The specification structure: `describe` and `it`.
  #
  module Spec
    require_relative 'spec/hooks'
    require_relative 'spec/example'
    require_relative 'spec/context'

    # The words the specification structure adds to the toplevel.
    #
    module DSL
      #
      # Define an example group.
      #
      def describe(topic, *tags, &block)
        settings = {:tags => tags}
        if Module === topic
          settings[:subject] = topic
          settings[:label]   = topic.name
        else
          settings[:label]   = topic
        end
        context = Spectrum::Spec::Context.new(settings, &block)
        $TEST_SUITE << context
        context
      end

      #
      # Define examples that several groups can share, to be brought in
      # with `it_behaves_like`.
      #
      def shared_examples_for(label, &block)
        Spectrum::Spec.shared_examples[label] = block
      end

      alias :shared_examples :shared_examples_for
    end

    #
    # Store for shared examples.
    #
    # @return [Hash] shared examples
    #
    def self.shared_examples
      @shared_examples ||= {}
    end

  end

end

extend Spectrum::Spec::DSL
