# -*- encoding: utf-8 -*-

require "unicode_utils/gc"

module UnicodeUtils

  GENERAL_CATEGORY_CODEPOINT_TYPE = {
    Lu: :Graphic, Ll: :Graphic, Lt: :Graphic, Lm: :Graphic, Lo: :Graphic,
    Mn: :Graphic, Mc: :Graphic, Me: :Graphic,
    Nd: :Graphic, Nl: :Graphic, No: :Graphic,
    Pc: :Graphic, Pd: :Graphic, Ps: :Graphic,
      Pe: :Graphic, Pi: :Graphic, Pf: :Graphic, Po: :Graphic,
    Sm: :Graphic, Sc: :Graphic, Sk: :Graphic, So: :Graphic,
    Zs: :Graphic, Zl: :Format, Zp: :Format,
    Cc: :Control, Cf: :Format, Cs: :Surrogate, Co: :Private_Use,
    # Cn is splitted into two types (Reserved and Noncharacter)!
    Cn: false
  } # :nodoc:

  CN_CODEPOINT_TYPE = Hash.new.tap { |h|
    h.default = :Reserved
    # Sixty-six code points are noncharacters
    ary = (0xFDD0..0xFDEF).to_a
    0.upto(16) { |d|
      ary << "#{d.to_s(16)}FFFE".to_i(16)
      ary << "#{d.to_s(16)}FFFF".to_i(16)
    }
    ary.each { |cp| h[cp] = :Noncharacter }
    raise "assertion error #{h.size}" unless h.size == 66
  } # :nodoc:

  # Get the code point type of the given +integer+ (must be instance
  # of Integer) as defined by the Unicode standard.
  #
  # If +integer+ is a codepoint (anything in
  # UnicodeUtils::Codepoint::RANGE), returns one of the following
  # symbols:
  #
  #   :Graphic
  #   :Format
  #   :Control
  #   :Private_Use
  #   :Surrogate
  #   :Noncharacter
  #   :Reserved
  #
  # For an exact meaning of these values, read the sections
  # "Conformance/Characters and Encoding" and "General
  # Structure/Types of Codepoints" in the Unicode standard.
  #
  # Following is a paraphrased excerpt:
  #
  # +Surrogate+, +Noncharacter+ and +Reserved+ codepoints are not
  # assigned to an _abstract character_. All other codepoints are
  # assigned to an abstract character.
  #
  # +Reserved+ codepoints are also called _Undesignated_ codepoints,
  # all others are _Designated_ codepoints.
  #
  # Returns nil if +integer+ is not a codepoint.
  def codepoint_type(integer)
    cpt = GENERAL_CATEGORY_CODEPOINT_TYPE[UnicodeUtils.gc(integer)]
    if false == cpt
      cpt = CN_CODEPOINT_TYPE[integer]
    end
    cpt
  end
  module_function :codepoint_type

end
