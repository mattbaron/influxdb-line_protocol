# frozen_string_literal: true

RSpec.describe Influxdb::LineProtocol do
  it "has a version number" do
    expect(Influxdb::LineProtocol::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
