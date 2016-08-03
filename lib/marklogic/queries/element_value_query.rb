module MarkLogic
  module Queries
    class ElementValueQuery < BaseQuery
      def initialize(element, search_value = nil, options = [], weight = 1.0)
        @element = element
        @search_value = search_value.nil? ? '*' : search_value
        options << 'wildcarded' if @search_value == '*' && !options.include?('wildcarded')
        @options = options.map { |o| query_value(o.to_s) }
        @weight = weight
      end

      def to_s
        element = query_value(@element)
        value = @search_value.class.ancestors.include?(BaseQuery) ? @search_value : query_value(@search_value)
        %{cts:element-value-query(xs:QName(#{element}), #{value}, (#{@options.join(', ')}), #{@weight}}
      end
    end
  end
end
