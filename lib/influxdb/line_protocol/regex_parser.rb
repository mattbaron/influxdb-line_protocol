class RegexParser

  def initialize(line_str)
    @line = line_str
    @measurement = nil
    @tags = {}
    @fields = {}
    @timestamp = nil

    parse
  end

  def dump
    puts "L: #{@line}\nM: #{@measurement}\nT: #{@tags}\nF: #{@fields}\nT: #{@timestamp}\nR: #{to_s}\n\n"
  end

  def parse
    raise ParseError if @line.nil? || @line.empty?

    raw_measurement, other = @line.split(/(?<!\\)\s/, 2)
    @measurement, raw_tags = raw_measurement.split(',', 2)

    raise ParseError if @measurement.nil? || @measurement.empty?

    parse_tags(raw_tags) unless raw_tags.nil?

    matches = other.match(/^(.+?)(\s+(\d+))?$/)
    raw_fields = matches[1]
    @timestamp = matches[3]

    parse_fields(raw_fields)
  end

  def to_s
    buff = @measurement.clone
    buff << ",#{render_tags}" if @tags.size.positive?
    buff << " #{render_fields}"
    buff << " #{@timestamp}" unless @timestamp.nil?
    buff
  end

  def render_tags
    buff = []
    @tags.each_pair do |k, v|
      buff << "#{k}=#{v}"
    end
    buff.join(',')
  end

  def render_fields
    buff = []
    @fields.each_pair do |k, v|
      if v.include?('%2C')
        v.gsub!('%2C', ',')
      end
      buff << "#{k}=#{v}"
    end
    buff.join(',')
  end

  def parse_tags(raw_tags)
    raise ParseError unless raw_tags.include?('=')

    raw_tags.split(/(?<!\\),/).each do |tag|
      tag_name, tag_value = tag.split(/(?<!\\)=/, 2)
      validate_tag(tag_name, tag_value)
      @tags[tag_name] = tag_value
    end
  end

  def parse_fields(raw_fields)
    raise ParseError unless raw_fields.include?('=')

    # Find strings with a comma in it.  Replace with percent encoding
    field_strings = raw_fields.scan(/".*?,.*?"/)
    field_strings.each do |string|
      raw_fields.gsub!(string, string.gsub(',', '%2C') )
    end

    raw_fields.split(',').each do |field|
      field_name, field_value = field.split('=', 2)
      validate_field(field_name, field_value)
      @fields[field_name] = field_value
    end
  end

  def validate_tag(name, value)
    [name, value].each do |str|
      raise ParseError unless !str.nil? && str.size.positive? && !str.match?(/(?<!\\)(\s|,|=)/)
    end
  end

  def validate_field(name, value)
    [name, value].each do |str|
      raise ParseError unless !str.nil? && str.size.positive?

      raise ParseError unless numeric?(value) || quoted_string?(value)
    end
  end

  def quoted_string?(value)
    return value.to_s.match(/^".*?"$/)
  end

  def numeric?(value)
    value.to_s.match?(/^-?((\d*\.\d+(e(\-|\+)\d+)?)|(\d+(u|i)?))$/)
  end

end

class ParseError < StandardError; end


lines = [
  'good f=123',
  'good f=2i',
  'good,abc=def,env=prod f1=4873.0',
  'good,abc=def,env=prod f1=4873.0,f2=3',
  'good,abc=def,env=prod f1=4873.0,f2=3 99999999',
  'good,dc=bar uptime="uptime 2, days",f=234',
  'good,bar=stage time=3.02,status="The status = blah, OK, not ok",name="Matt, Baron"   999999999',
  'good,bar=stage time=9.02,status="The status = blah"',
  'bad,dc=foo\ bar,env=prod,agent_name=Matt,blah=\ f\=1234,f2=234 9999999',
  'bad,dc= elr,env=prod',
  'bad,dc=foo foo=bar',
  'bad f1=',
  'bad,foo=bar abc=123,def=1354 foo=234 999999',
  'this is a test of the emergency',
  '',
  ' '
]

lines.each do |line|
  RegexParser.new(line).dump
rescue ParseError => e
  puts "#{e} on Line: #{line}\n\n"
end
