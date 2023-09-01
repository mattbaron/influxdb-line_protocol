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
        puts "M: #{@measurement}\nT: #{@tags}\nF: #{@fields}\nT: #{@timestamp}\nL: #{to_s}\n\n"
      end

      def hash_to_s(hash)
        buff = []
        hash.each do |k, v|
          buff << "#{k}=#{v}"
        end
        buff.join(',')
      end

      def to_s
        buff = @measurement

        if tags.size.positive?
          buff += ",#{hash_to_s(@tags)}"
        end

        buff += " #{hash_to_s(@fields)} #{@timestamp}"

        buff
      end

      def validate
        raise InvalidFormatError, 'Line has no fields' if @fields.size.zero?

        raise InvalidTimestampError, 'Invalid timestamp' unless @timestamp.match?(/^\d+$/)

        fields.each do |k, v|
          raise InvalidFieldError, "Invalid field value #{v}" unless v.start_with?('"') || numeric?(v)
        end
      end

      def numeric?(value)
        value.match?(/^-?((\d*\.\d+(e(\-|\+)\d+)?)|(\d+(u|i)?))$/)
      end

      def has_tag?(tag_name)
        @tags.key?(tag_name)
      end
    end
  end
end
