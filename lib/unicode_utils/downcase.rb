# encoding: utf-8

require "unicode_utils/simple_downcase"
require "unicode_utils/read_special_casing_map"

module UnicodeUtils

  SPECIAL_DOWNCASE_MAP = Impl.read_special_casing_map("special_lc_map")

  def downcase(str)
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
