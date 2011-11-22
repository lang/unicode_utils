# -*- encoding: utf-8 -*-

require "unicode_utils/east_asian_width"
require "unicode_utils/nfc"

module UnicodeUtils

  # Fixed pitch fonts display certain east asian characters with
  # double the width of other characters (e.g. latin characters or
  # a space). This function calculates a display width for +str+ based
  # on the EastAsianWidth property of its codepoints.
  #
  # Converts str into Normalization Form C and counts codepoints,
  # where codepoints with an East Asian Width of Wide or Fullwidth
  # count double, all other codepoints count one.
  #
  # Examples:
  #
  #   require "unicode_utils/display_width"
  #   "別れ".length => 2
  #   UnicodeUtils.display_width("別れ") => 4
  #   "12".length => 2
  #   UnicodeUtils.display_width("12") => 2
  #
  # See also: UnicodeUtils.east_asian_width
  def display_width(str)
    UnicodeUtils.nfc(str).each_codepoint.reduce(0) { |sum, cp|
      sum +
        case UnicodeUtils.east_asian_width(cp)
        when :Wide, :Fullwidth then 2
        else 1
        end
    }
  end
  module_function :display_width

end
