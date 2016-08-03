module MarkLogic
  module Queries
    class AndQuery < BaseQuery
      def initialize(*args)
        @queries = args.flat_map { |i| i }
      end

      def to_s
        sub_queries = @queries.map(&:to_s).join(',')
        %{cts:and-query((#{sub_queries}))}
      end
    end
  end
end
