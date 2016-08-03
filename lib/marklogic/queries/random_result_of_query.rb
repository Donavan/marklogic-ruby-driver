module MarkLogic
  module Queries
    class RandomResultOfQuery < BaseQuery
      def initialize(query)
        @query = query
      end

      def to_s
        %{declare variable $idx := xdmp:random(xdmp:estimate(#{@query})); #{@query}[$idx]}
      end
    end
  end
end
