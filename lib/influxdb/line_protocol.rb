# frozen_string_literal: true

require "influxdb/line_protocol/version"
require "influxdb/line_protocol/parser"
require "influxdb/line_protocol/metric"

module InfluxDB
  module LineProtocol
    class Error < StandardError; end
    class ParseError <  Error; end
    class InvalidFormatError < Error; end
    class InvalidFieldError < Error; end
    class InvalidTagError < Error; end
    class InvalidTimestampError < Error; end
  end
end
