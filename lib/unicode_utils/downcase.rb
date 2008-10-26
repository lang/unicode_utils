# encoding: utf-8

require "unicode_utils/simple_downcase"
require "unicode_utils/read_special_casing_map"

module UnicodeUtils

  SPECIAL_DOWNCASE_MAP = Impl.read_special_casing_map("special_lc_map")

  # Perform a full case-conversion of +str+ to lowercase according to
  # the Unicode standard.
  #
  # Examples:
  #
  #     UnicodeUtils.downcase "ᾈ" => "ᾀ"
  #
  # Note: The current implementation ignores the +language_id+
  # argument and doesn't deal with language and context specific
  # cases. This affects text in the languages Lithuanian, Turkish and
  # Azeri and the greek letter sigma in a special position. A future
  # version of UnicodeUtils will fix this. All other languages are
  # fully supported according to the Unicode standard.
  def downcase(str, language_id = nil)
    String.new.force_encoding(str.encoding).tap { |res|
      str.each_codepoint { |cp|
        special_mapping = SPECIAL_DOWNCASE_MAP[cp]
        if special_mapping
          special_mapping.each { |m| res << m }
        else
          res << (SIMPLE_DOWNCASE_MAP[cp] || cp)
        end
      }
    }
  end
  module_function :downcase

end
