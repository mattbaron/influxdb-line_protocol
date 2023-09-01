require 'influxdb/line_protocol'

lines = [
  'foo,dc=blah f=123 93842938439',
  'foo,dc=sneeb f=456'
]

lines.each do |line|
  parser = InfluxDB::LineProtocol::Parser.new(line)
  metric = parser.parse
  metric.dump
end
