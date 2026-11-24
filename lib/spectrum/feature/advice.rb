module Spectrum
  class Feature

    # The step definitions of a feature: for each of `given`, `when` and
    # `then`, a table of description patterns and their procedures.
    #
    class Advice

      #
      attr :table

      #
      def initialize
        @table = Hash.new{ |h,k| h[k] = {} }
      end

      #
      def initialize_copy(original)
        @table = Hash.new{ |h,k| h[k] = {} }
        original.table.each{ |type, defs| @table[type] = defs.dup }
      end

      #
      def [](type)
        @table[type.to_sym]
      end

    end

  end
end
