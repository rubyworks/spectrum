require_relative '../spectrum'
require_relative 'feature/advice'
require_relative 'feature/step'
require_relative 'feature/scenario'
require_relative 'feature/featurette'
require_relative 'feature/feature'

module Spectrum

  class Feature

    # The words the feature structure adds to the toplevel.
    #
    module DSL
      #
      # Define a feature.
      #
      def Feature(label, &block)
        location = caller_locations(1,1).first
        require_featurettes(File.dirname(location.absolute_path || location.path))
        feature = Spectrum::Feature.new(:label=>label, &block)
        $TEST_SUITE << feature
        feature
      end

      alias :feature :Feature

      #
      # Require any featurettes located in `{feature_dir}/featurettes` directory.
      #
      def require_featurettes(feature_dir)
        featurettes_dir = File.join(feature_dir, 'featurettes')
        if File.directory?(featurettes_dir)
          Dir[File.join(featurettes_dir, '*.rb')].sort.each do |file|
            require file
          end
        end
      end
    end

  end

end

extend Spectrum::Feature::DSL
