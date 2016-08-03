module MarkLogic
  module DatabaseSettings
    class GeospatialElementIndex
      attr_accessor :localname, :facet

      def initialize(element_name, options = {})
        @localname = element_name
        @coordinate_system = options[:coordinate_system] || MarkLogic::GEO_WGS84
        @point_format = options[:point_format] || MarkLogic::POINT
        @range_value_positions = options[:range_value_positions] || false
        @invalid_values = options[:invalid_values] || MarkLogic::REJECT
        @facet = options[:facet] || false
      end

      def key
        %(#{self.class}-#{@localname})
      end

      def append_to_db(database)
        database.add_index('geospatial-element-index', self)
      end

      def to_json(_options = nil)
        {
          'geospatial-element-index' => {
            'namespace-uri' => '',
            'localname' => @localname,
            'coordinate-system' => @coordinate_system,
            'point-format' => @point_format,
            'range-value-positions' => @range_value_positions,
            'invalid-values' => @invalid_values
          }
        }
      end
    end
  end
end
