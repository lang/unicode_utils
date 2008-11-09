# -*- encoding: utf-8 -*-

require "unicode_utils/read_names"
require "unicode_utils/hangul_syllable_decomposition"
require "unicode_utils/jamo_short_name"

module UnicodeUtils

  NAME_MAP = Impl.read_names("names") # :nodoc:

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
  def name(char)
    cp = char.ord
    NAME_MAP[cp] ||
      case cp
      when 0x3400..0x4DB5, 0x4E00..0x9FC3, 0x20000..0x2A6D6
        "CJK UNIFIED IDEOGRAPH-#{sprintf('%04x', cp).upcase}"
      when 0xAC00..0xD7A3
        "HANGUL SYLLABLE ".tap do |n|
          hangul_syllable_decomposition(char).each_char { |c|
            n << (jamo_short_name(c) || '')
          }
        end
      end
  end
  module_function :name

end
