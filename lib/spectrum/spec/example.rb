module Spectrum
  module Spec

    # Example behavior.
    #
    # This is the `it` in your specs.
    #
    class Example

      #
      # Defines a specification procedure.
      #
      def initialize(options={}, &procedure)
        @parent = options[:parent]
        @label  = options[:label]
        @skip   = options[:skip]
        @tags   = options[:tags] || []
        @topic  = options[:topic]
        @file   = options[:file]
        @line   = options[:line]

        # An example without a block is one still to be written.
        @procedure = procedure || proc{ raise NotImplementedError, "example not written" }
      end

      #
      # The context to which this example belongs.
      #
      attr :parent

      #
      # Description of example.
      #
      attr :label

      #
      # List of identifying tags attached to example. These should
      # be a list of Symbols, with an optional Symbol=>Object tail element.
      #
      attr :tags

      #
      # A map of Symbol => Object, which is taken from the end of `tags`.
      # Unlike tags, keys allow key-value relationships, rather than just
      # symbolic names.
      #
      def keys
        Hash === tags.last ? tags.last : {}
      end

      #
      # In RSpec data keys are called metadata.
      #
      alias_method :metadata, :keys

      #
      # Test procedure, in which test assertions should be made.
      #
      attr :procedure

      #
      # Rubytest uses `type` to describe the nature of a test object.
      #
      def type
        'it'
      end

      #
      # Skip this spec?
      #
      def skip?
        @skip
      end

      #
      # Set +true+ to skip, or String to skip with reason.
      #
      def skip=(reason)
        @skip = reason
      end

      #
      # Return label string.
      #
      # @return [String]
      #
      def to_s
        label.to_s
      end

      #
      # Rubytest looks for `topic` as the desciption of the subject.
      #
      def topic
        @topic.to_s
      end

      #
      # Location of the example's definition.
      #
      def source_location
        [@file, @line]
      end

      #
      # If +match+ is a Regexp or String, match against label.
      # If +match+ is a Hash, match against keys.
      # If +match+ is a Symbol, match against tags.
      #
      def match?(match)
        case match
        when Regexp, String
          match === label.to_s
        when Hash
          match.any?{ |k,m| m === keys[k] }
        else
          tags.include?(match.to_sym)
        end
      end

      #
      # Execute example: the before hooks, the example, and the after
      # hooks, which run whether or not the example passes. Hooks of the
      # contexts around the example's own apply too: before hooks from
      # the outermost in, after hooks from the innermost out.
      #
      # Each example runs in a scope of its own, so nothing one example
      # sets is seen by the next.
      #
      def call
        scope    = Scope.new(parent)
        contexts = parent.lineage

        contexts.each do |context|
          context.hooks.run(self, :before, :each, scope)
        end
        begin
          scope.instance_exec(&procedure)
        ensure
          contexts.reverse_each do |context|
            context.hooks.run(self, :after, :each, scope)
          end
        end
      end

      #
      # Example can be converted to a Proc object.
      #
      # @return [Proc]
      #
      def to_proc
        lambda{ call }
      end

      # The object an example runs in. It has the helper methods, `let`
      # values and `subject` of the example's context, and of the
      # contexts around that one.
      #
      class Scope
        include World

        #
        # @param [Context] group
        #
        def initialize(group)
          @_group = group
          @_let   = {}
          extend group.scope
        end

        #
        # Mark the example as still to be done.
        #
        # @raise [NotImplementedError] Example is a "todo".
        #
        def pending(message=nil)
          raise NotImplementedError.new(message || "pending")
        end

        #
        # The subject of the example: what a `subject` block in the
        # context returns, or else a new instance of the class being
        # described.
        #
        def subject
          return @_subject if defined?(@_subject)
          @_subject = defined?(super) ? super : described_class.new
        end

        #
        # The class being described, if the context names one.
        #
        def described_class
          group = @_group
          while group
            return group.subject if Module === group.subject
            group = group.parent
          end
          nil
        end

      private

        #
        # Handle implicit subject: a method the example doesn't have is
        # sent to the subject, if there is one that has it.
        #
        def method_missing(s, *a, &b)
          if __subject__? && subject.respond_to?(s)
            subject.public_send(s, *a, &b)
          else
            super
          end
        end

        #
        def respond_to_missing?(s, include_all=false)
          (__subject__? && subject.respond_to?(s)) || super
        end

        # Is there a subject to speak of?
        def __subject__?
          defined?(@_subject) || singleton_class.instance_method(:subject).owner != Scope || Class === described_class
        end

      end

    end

  end
end
