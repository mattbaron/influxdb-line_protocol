module InfluxDB
  module LineProtocol
    class Parser
      attr_reader :metric

      def initialize(line)
        @line = line
        @index = -1
        @delim = [' ', ',', '=', nil]
        @tokens = []

        @token = nil
        @value = nil

        @metric = InfluxDB::LineProtocol::Metric.new
      end

      def peek
        @line[@index + 1]
      end

      def parse_error(type)
        raise StandardError, "Parse error - Expected #{:WORD}"
      end

      def next_char
        @index += 1
        @line[@index]
      end

      # def tokenize
      #   tokens = []
      #   loop do
      #     tokens << next_token(@delim)
      #     puts tokens.to_json
      #     break if tokens.last == :NIL
      #   end
      #   tokens
      # end

      def next_token
        buff = []
        done = false
        in_quote = false

        while !done
          c = next_char

          case c
          when '"'
            buff << c
            if in_quote
              done = true
              in_quote = false
            else
              in_quote = true
            end
          when ' '
            return @token = :SPACE unless in_quote
            buff << c
          when ','
            return @token = :COMMA unless in_quote
            buff << c
          when '='
            return @token = :EQUAL unless in_quote
            buff << c
          when nil
            return @token = :NIL unless in_quote
            raise StandardError, 'Unexpected EOF'
          when '\\'
            buff << '\\'
            buff << next_char
          else
            buff << c
          end

          done = @delim.include?(peek) && !in_quote
        end

        @value = buff.join('')
        @token = :WORD, @value
      end

      def parse_measurement
        type, measurement = next_token
        parse_error(:WORD) unless type == :WORD

        @metric.measurement = measurement
      end

      def parse_tag
        type, tag_name = next_token

        return true if type == :SPACE

        return false if type == :COMMA

        parse_error(:WORD) unless type == :WORD

        parse_error(:EQUAL) unless next_token == :EQUAL

        type, tag_value = next_token

        parse_error(:WORD) unless type == :WORD

        @metric.tags[tag_name] = tag_value

        false
      end

      def parse_tags
        done = false
        until done
          done = parse_tag
        end
      end

      def parse_field
        type, field_name = next_token

        return true if type == :NIL

        return true if type == :SPACE

        return false if type == :COMMA

        parse_error(:WORD) unless type == :WORD

        parse_error(:EQUAL) unless next_token == :EQUAL

        type, field_value = next_token

        parse_error(:WORD) unless type == :WORD

        @metric.fields[field_name] = field_value

        return false
      end

      def parse_fields
        done = false
        until done
          done = parse_field
        end
      end

      def parse
        parse_measurement

        type, value = next_token

        if type == :COMMA
          parse_tags
        end

        parse_fields

        type, value = next_token
        if type != :NIL
          @metric.timestamp = value
        end

        @metric
      end

      def validate
        raise StandardError, 'No fields found' if @fields.size.zero?
      end
    end
  end
end