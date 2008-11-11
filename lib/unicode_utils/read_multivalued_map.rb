# -*- encoding: utf-8 -*-

module UnicodeUtils

  module Impl # :nodoc:

    def self.read_multivalued_map(filename)
      path = File.join(File.dirname(__FILE__), "..", "..", "cdata", filename)
      Hash.new.tap { |map|
        File.open(path, "r:US-ASCII:-") do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            cp = buffer.to_i(16)
            mapping = []
            while input.read(6, buffer).getbyte(0) != 120
              mapping << buffer.to_i(16)
            end
            map[cp] = mapping
          end
        end
      }
    end

  end

end
