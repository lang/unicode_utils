# encoding: utf-8

module UnicodeUtils

  module Impl # :nodoc:

    def self.read_names
      path = File.join(File.dirname(__FILE__), "..", "..", "cdata", "names")
      Hash.new.tap { |map|
        File.open(path, "r:US-ASCII:-") do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            map[buffer.to_i(16)] = input.gets.tap { |x| x.chomp! }
          end
        end
      }
    end

  end

  NAME_MAP = Impl.read_names

  # Get the Unicode name of the single codepoint in str.
  #
  # Example:
  #
  #     UnicodeUtils.name "ᾀ" => "GREEK SMALL LETTER ALPHA WITH PSILI AND YPOGEGRAMMENI"
  def name(str)
    NAME_MAP[str.codepoints.first]
  end
  module_function :name

end
