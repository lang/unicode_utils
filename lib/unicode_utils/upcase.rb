# encoding: utf-8

require "unicode_utils/simple_upcase"
require "unicode_utils/read_special_casing_map"

module UnicodeUtils

  SPECIAL_UPCASE_MAP = Impl.read_special_casing_map("special_uc_map")

  def upcase(str)
    String.new.force_encoding(str.encoding).tap { |res|
      str.each_codepoint { |cp|
        special_mapping = SPECIAL_UPCASE_MAP[cp]
        if special_mapping
          special_mapping.each { |m| res << m }
        else
          res << (SIMPLE_UPCASE_MAP[cp] || cp)
        end
      }
    }
  end
  module_function :upcase

end
