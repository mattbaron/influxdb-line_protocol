module InfluxDB
  module LineProtocol
    class Metric
      attr_accessor :measurement, :tags, :fields, :timestamp, :default_timestamp

      @@default_timestamp = sprintf("%d", Time.now.to_f * (10 ** 9))

      def initialize
        @measurement = nil
        @tags = {}
        @fields = {}
        @timestamp = @@default_timestamp
      end

      def dump
        puts "M: #{@measurement}\nT: #{@tags}\nF: #{@fields}\nT: #{@timestamp}\n\n"
      end

      def has_tag?(tag_name)
        @tags.key?(tag_name)
      end
    end
  end
end
