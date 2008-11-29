# -*- encoding: utf-8 -*-

require "test/unit"

require "unicode_utils/codepoint"

class TestCodepoint < Test::Unit::TestCase

  def test_ord
    assert_equal 0x20ac, UnicodeUtils::Codepoint.new(0x20ac).ord
  end

  def test_uplus
    assert_equal "U+20AC", UnicodeUtils::Codepoint.new(0x20ac).uplus
  end

  def test_uplus_more_than_four_digits
    assert_equal "U+10FFFF", UnicodeUtils::Codepoint.new(0x10FFFF).uplus
  end

  def test_uplus_less_than_four_digits
    assert_equal "U+0061", UnicodeUtils::Codepoint.new(0x61).uplus
  end

  def test_name
    assert_equal "EURO SIGN", UnicodeUtils::Codepoint.new(0x20ac).name
  end

  def test_to_s
    assert_equal 0x20ac.chr(Encoding::UTF_8), UnicodeUtils::Codepoint.new(0x20ac).to_s
  end

  def test_hexbytes
    assert_equal "e2,82,ac", UnicodeUtils::Codepoint.new(0x20ac).hexbytes
  end

  def test_hexbytes_one_byte
    assert_equal "61", UnicodeUtils::Codepoint.new(0x61).hexbytes
  end

  def test_inspect
    str = UnicodeUtils::Codepoint.new(0x20ac).inspect
    assert str.include?("U+")
    assert str.include?("€")
    assert str.include?("EURO SIGN")
    assert str.include?("utf8:e2,82,ac")
  end

end
