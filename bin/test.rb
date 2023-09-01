require 'influxdb/line_protocol'

metrics = []

lines = [
  'foo\ bar,dc=blah f=123 93842938439',
  'foo,dc=sneeb f=456',
  'foo,name=Matt\ Baron f=999,size=3,status="Running , 0 days"',
  'foo,dc=blah f=123,f2="abc"',
  'sneeb f=678 888888888',
  'bad,foo=bar 3993484883',
  'good f=983i,name="Matt Baron 1234" 92348239482394',
  'good f=-0.883',
  'good,abc=def f=0.088',
  'good f=9988.2',
  'bad,dc=bar f=-87.23, 234234',
  'good f=999',
  'good,dc=foo,abc=sdfa f=123',
  'foo'
]

lines.each do |line|
  parser = InfluxDB::LineProtocol::Parser.new(line)
  metric = parser.parse
  metric.dump

  metric.validate

  metrics << metric
rescue InfluxDB::LineProtocol::Error => e
  puts "#{e}\n\n"
end

File.write('metrics.txt', metrics.join("\n"))
