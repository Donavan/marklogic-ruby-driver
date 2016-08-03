module MarkLogic
  module DatabaseSettings
    class ElementWordLexicon
      def initialize(localname, collation = DEFAULT_COLLATION)
        @localname = localname
        @collation = collation
      end

      def append_to_db(database)
        database.add_index('element-word-lexicon', self)
      end

      def key
        %(#{self.class}-#{@localname})
      end

      def to_json(_options = nil)
        {
          'element-word-lexicon' => {
            'namespace-uri' => '',
            'localname' => @localname,
            'collation' => @collation
          }
        }
      end
    end
  end
end
