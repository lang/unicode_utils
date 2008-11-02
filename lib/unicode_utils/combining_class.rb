# encoding: utf-8

module UnicodeUtils

  module Impl # :nodoc:

    def self.read_combining_class_map
      path = File.join(File.dirname(__FILE__),
                       "..", "..", "cdata", "combining_class_map")
      Hash.new.tap { |map|
        File.open(path, "r:US-ASCII:-") do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          cc_buffer = "x" * 2
          cc_buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            map[buffer.to_i(16)] = input.read(2, cc_buffer).to_i(16)
          end
        end
      }
    end

  end

  COMBINING_CLASS_MAP = Impl.read_combining_class_map

  # Get the combining class of the given character as an integer in
  # the range 0..255.
  def combining_class(char)
    COMBINING_CLASS_MAP[char.ord] || 0
  end
  module_function :combining_class

end
