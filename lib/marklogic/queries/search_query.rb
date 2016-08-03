module MarkLogic
  module Queries
    class SearchQuery < BaseQuery
      def initialize(sub_query, what = 'fn:doc()')
        @sub_query = sub_query
        @what = what
      end

      def to_s
        %{cts:search(#{@what}, #{@sub_query})}
      end
    end
  end
end
