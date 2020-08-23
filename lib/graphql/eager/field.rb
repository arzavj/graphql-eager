module GraphQL
  module Eager
    module Field
      attr_reader :eager

      # Override #initialize to take a new argument:
      def initialize(*args, eager: {}, **kwargs, &block)
        @eager = eager
        # Pass on the default args:
        super(*args, **kwargs, &block)
      end
    end
  end

  class Schema
    class Field
      prepend Eager::Field
    end
  end
end
