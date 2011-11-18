# encoding: utf-8

require "test/unit"

require "unicode_utils"

# Tests behaviour in Unicode 6.0.0 that wasn't in the previously
# supported standard. That means each one of these assertions fails
# with UnicodeUtils 1.0.0.
class TestUnicode_6_0_0 < Test::Unit::TestCase

  def test_char_name
    assert_equal "CYRILLIC CAPITAL LETTER PE WITH DESCENDER",
      UnicodeUtils.char_name("\u{524}")
    assert_equal "SAMARITAN LETTER QUF",
      UnicodeUtils.char_name("\u{812}")
    assert_equal "TIBETAN SUBJOINED SIGN INVERTED MCHU CAN",
      UnicodeUtils.char_name("\u{F8F}")
    assert_equal "CANADIAN SYLLABICS TLHWE",
      UnicodeUtils.char_name("\u{18E8}")
    assert_equal "EGYPTIAN HIEROGLYPH F040",
      UnicodeUtils.char_name("\u{1312B}")
    assert_equal "STEAMING BOWL",
      UnicodeUtils.char_name("\u{1F35C}")
    assert_equal "HANGUL JUNGSEONG ARAEA-A",
      UnicodeUtils.char_name("\u{d7c5}")
    assert_equal "CJK UNIFIED IDEOGRAPH-2A700",
      UnicodeUtils.char_name("\u{2a700}")
    assert_equal "CJK UNIFIED IDEOGRAPH-2B81D",
      UnicodeUtils.char_name("\u{2b81d}")
  end

  def test_grep
    assert_equal [0x1F35C], UnicodeUtils.grep(/Steaming Bowl/).map(&:ord)
  end

  def test_simple_upcase
    assert_equal "\u{2c7e}", UnicodeUtils.simple_upcase("\u{23f}")
  end

  def test_simple_downcase
    assert_equal "\u{23f}", UnicodeUtils.simple_downcase("\u{2c7e}")
  end

end
