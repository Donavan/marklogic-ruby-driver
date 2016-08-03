module MarkLogic
  module Queries
    class ElementQuery < BaseQuery
      def initialize(element, search_value = nil)
        @element = element
        @search_value = search_value.nil? ? 'cts:and-query( () )' : query_value(search_value.to_s)
      end

      def to_s
        element = query_value(@element)
        %{cts:element-query(xs:QName(#{element}), #{@search_value})}
      end
    end
  end
end
