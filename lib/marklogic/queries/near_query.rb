module MarkLogic
  module Queries
    class NearQuery < BaseQuery
      def initialize(queries, distance = 10, distance_weight = 1.0, options = {})
        @queries = queries
        @distance = distance
        @distance_weight = distance_weight
        @ordered = options.delete(:ordered)
      end

      def to_json
        json = {
          'near-query' => {
            'queries' => @queries.map(&:to_json)
          }
        }

        json['near-query']['queries'].push('distance' => @distance) if @distance
        json['near-query']['queries'].push('distance-weight' => @distance_weight) if @distance_weight
        json['near-query']['queries'].push('ordered' => @ordered)
        json
      end

      def to_s
        queries = @queries.map(&:to_s).join(',')
        ordered = (@ordered == true ? %("ordered") : %("unordered")) unless @ordered.nil?
        %{cts:near-query((#{queries}),#{@distance},(#{ordered}),#{@distance_weight})}
      end
    end
  end
end
