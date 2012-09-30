# encoding: utf-8

require "test/unit"

require "unicode_utils"

# Tests behaviour in Unicode 6.2.0 that wasn't in the previously
# supported standard. That means each one of these tests fails
# with UnicodeUtils 1.3.0.
class TestUnicode_6_2_0 < Test::Unit::TestCase

  def test_east_asian_width
    assert_equal :Neutral, UnicodeUtils.east_asian_width(0x11a3)
  end

  def test_display_width
    assert_equal 1, UnicodeUtils.display_width("\u{11a3}")
  end

  def test_char_display_width
    assert_equal 1, UnicodeUtils.char_display_width(0x11a3)
  end

  def test_each_grapheme
    # don't break between regional indicator symbols
    assert_equal ["\u{1F1E6}\u{1F1E7}"],
      UnicodeUtils.each_grapheme("\u{1F1E6}\u{1F1E7}").to_a
  end

  def test_sid
    # name alias of type correction introduced
    assert_equal "SYRIAC SUBLINEAR COLON SKEWED LEFT", UnicodeUtils.sid(0x709)
  end

  def test_char_name
    assert_equal "TURKISH LIRA SIGN", UnicodeUtils.char_name(0x20ba)
  end

  def test_general_category
    assert_equal :Currency_Symbol, UnicodeUtils.general_category(0x20ba)
  end

  def test_each_word
    # don't break between regional indicator symbols
    assert_equal ["foo", "\u{1F1E6}\u{1F1E7}", "bar"],
      UnicodeUtils.each_word("foo\u{1F1E6}\u{1F1E7}bar").to_a
  end

end
