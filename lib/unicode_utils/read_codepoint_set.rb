# -*- encoding: utf-8 -*-

module UnicodeUtils

  module Impl # :nodoc:

    def self.read_codepoint_set(filename)
      path = File.join(File.dirname(__FILE__), "..", "..", "cdata", filename)
      Hash.new.tap { |set|
        File.open(path, "r:US-ASCII:-") do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            set[buffer.to_i(16)] = true
          end
        end
      }
    end

  end

end
