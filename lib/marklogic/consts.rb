module MarkLogic
  ROOT_COLLATION = 'http://marklogic.com/collation/'.freeze
  CODEPOINT_COLLATION = 'http://marklogic.com/collation/codepoint'.freeze
  DEFAULT_COLLATION = ROOT_COLLATION

  GEO_WGS84 = 'wgs84'.freeze
  GEO_RAW = 'raw'.freeze

  POINT = 'point'.freeze
  LONG_LAT_POINT = 'long-lat-point'.freeze

  INT = 'int'.freeze
  UNSIGNED_INT = 'unsignedInt'.freeze
  LONG = 'long'.freeze
  UNSIGNED_LONG = 'unsignedLong'.freeze
  FLOAT = 'float'.freeze
  DOUBLE = 'double'.freeze
  DECIMAL = 'decimal'.freeze
  DATE_TIME = 'dateTime'.freeze
  TIME = 'time'.freeze
  DATE = 'date'.freeze
  G_YEAR_MONTH = 'gYearMonth'.freeze
  G_YEAR = 'gYear'.freeze
  G_MONTH = 'gMonth'.freeze
  G_DAY = 'gDay'.freeze
  YEAR_MONTH_DURATION = 'yearMonthDuration'.freeze
  DAY_TIME_DURATION = 'dayTimeDuration'.freeze
  STRING = 'string'.freeze
  ANY_URI = 'anyURI'.freeze

  IGNORE = 'ignore'.freeze
  REJECT = 'reject'.freeze
end
