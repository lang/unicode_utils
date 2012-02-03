# encoding: utf-8

require "test/unit"

require "unicode_utils"

# Tests behaviour in Unicode 6.0.1 that wasn't in the previously
# supported standard. That means each one of these assertions fails
# with UnicodeUtils 1.0.2.
class TestUnicode_6_0_1 < Test::Unit::TestCase

  def test_gc
    assert_equal :Po, UnicodeUtils.gc(0xa7)
    assert_equal :Po, UnicodeUtils.gc(0xb6)
    assert_equal :Po, UnicodeUtils.gc(0xf14)
    assert_equal :Po, UnicodeUtils.gc(0x1360)
    assert_equal :Po, UnicodeUtils.gc(0x10102)
    0x3248.upto(0x324F) { |cp|
      assert_equal :No, UnicodeUtils.gc(cp)
    }
  end

  def test_char_name
    assert_equal "CJK UNIFIED IDEOGRAPH-9FCC", UnicodeUtils.char_name(0x9fcc)
    assert_equal "ARABIC LETTER BEH WITH SMALL V BELOW", UnicodeUtils.char_name(0x8a0)
    assert_equal "SLEEPING FACE", UnicodeUtils.char_name(0x1f634)
  end

  def test_canonical_decomposition
    assert_equal "\u{11131}\u{11127}", UnicodeUtils.canonical_decomposition("\u{1112e}")
    assert_equal "\u{11132}\u{11127}", UnicodeUtils.canonical_decomposition("\u{1112f}")
  end

  def test_nfd
    assert_equal "\u{11131}\u{11127}", UnicodeUtils.nfd("\u{1112e}")
    assert_equal "\u{11132}\u{11127}", UnicodeUtils.nfd("\u{1112f}")
  end

  def test_nfc
    assert_equal "\u{1112e}", UnicodeUtils.nfc("\u{11131}\u{11127}")
    assert_equal "\u{1112f}", UnicodeUtils.nfc("\u{11132}\u{11127}")
  end

  def test_casefold
    assert_equal "\u{2d2d}", UnicodeUtils.casefold("\u{10cd}")
    assert_equal "\u{a793}", UnicodeUtils.casefold("\u{a792}")
  end

  def test_combining_class
    assert_equal 7, UnicodeUtils.combining_class(0x116b7)
  end

  def test_lowercase_char?
    assert_equal true, UnicodeUtils.lowercase_char?(0x2071)
  end

end
