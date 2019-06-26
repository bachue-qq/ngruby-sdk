# frozen_string_literal: true

require 'faraday'
require 'tempfile'
require 'pathname'

module SpecHelpers
  def create_temp_file(kilo_size:)
    fake_data = ('A' + 'b' * 4093 + "\r\n").freeze
    temp_file = File.open(Pathname.new('/tmp').join("qiniu_#{kilo_size}k"), 'wb')
    written = 0
    size = kilo_size * 1024
    rest = size
    while written < size
      to_write = [rest, fake_data.size].min
      temp_file.write fake_data[0...to_write]
      rest -= to_write
      written += to_write
    end
    temp_file.path
  ensure
    temp_file&.close
  end

  def temp_file_from_url(url)
    temp_file = File.open(Pathname.new('/tmp').join(File.basename(url)), 'wb')
    temp_file << Faraday.get(url).body
    temp_file.path
  ensure
    temp_file&.close
  end
end
