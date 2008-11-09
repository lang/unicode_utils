# -*- encoding: utf-8 -*-

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

  NAME_MAP = Impl.read_names # :nodoc:

  # Get the normative Unicode name of the given character.
  #
  # Private Use codepoints have no name, this function returns nil for
  # such codepoints.
  #
  # All control characters have the special name "<control>". All
  # other characters have a unique name.
  #
  # Example:
  #
  #     UnicodeUtils.name "ᾀ" => "GREEK SMALL LETTER ALPHA WITH PSILI AND YPOGEGRAMMENI"
  #     UnicodeUtils.name "\t" => "<control>"
  def name(str)
    cp = str.ord
    NAME_MAP[cp] ||
      case cp
      when 0x3400..0x4DB5, 0x4E00..0x9FC3, 0x20000..0x2A6D6
        "CJK UNIFIED IDEOGRAPH-#{sprintf('%04x', cp).upcase}"
      end
  end
  module_function :name

end
