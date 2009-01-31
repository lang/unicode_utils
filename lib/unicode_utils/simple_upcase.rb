# -*- encoding: utf-8 -*-

require "unicode_utils/read_cdata"

module UnicodeUtils

  SIMPLE_UPCASE_MAP = Impl.read_codepoint_map("simple_uc_map") # :nodoc:

  # Map each codepoint in +str+ that has a single codepoint
  # uppercase-mapping to that uppercase mapping. +str+ is assumed to be
  # in a unicode encoding. The original string is not modified. The
  # returned string has the same encoding and same length as the
  # original string.
  #
  # This function is locale independent.
  #
  # Examples:
  #
  #   require "unicode_utils/simple_upcase"
  #   UnicodeUtils.simple_upcase("ümit: 123") => "ÜMIT: 123"
  #   UnicodeUtils.simple_upcase("weiß") => "WEIß"
  def simple_upcase(str)
    String.new.force_encoding(str.encoding).tap { |res|
      str.each_codepoint { |cp|
        res << (SIMPLE_UPCASE_MAP[cp] || cp)
      }
    }
  end
  module_function :simple_upcase

end
