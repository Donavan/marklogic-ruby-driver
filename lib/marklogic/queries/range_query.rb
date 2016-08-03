module MarkLogic
  module Queries
    class RangeQuery < BaseQuery
      attr_accessor :name, :range_type

      def initialize(name, operator, range_type, value, options = {})
        @name = name.to_s
        @operator = operator.to_s.upcase
        @range_type = range_type
        @value = value
        @options = options || {}
        @weight = @options.delete(:weight) || 1.0
      end

      attr_writer :operator

      def operator
        case @operator
        when 'LT'
          '<'
        when 'LE'
          '<='
        when 'GT'
          '>'
        when 'GE'
          '>='
        when 'EQ'
          '='
        when 'NE'
          '!='
        else
          @operator
        end
      end

      attr_writer :options

      def options
        opts = []
        @options.each do |k, v|
          case k.to_s
          when 'collation', 'min_occurs', 'max_occurs', 'score_function', 'slope_factor'
            opts << %("#{k.to_s.tr('_', '-')}=#{v}")
          when 'cached'
            opts << (v == true ? %("cached") : %("uncached"))
          when 'synonym'
            opts << %("#{k}")
          else
            opts << %("#{v}")
          end
        end

        opts
      end

      def to_s
        value = query_value(@value, @range_type)
        %{cts:json-property-range-query("#{@name}","#{operator}",(#{value}),(#{options.join(',')}),#{@weight})}
      end
    end
  end
end
