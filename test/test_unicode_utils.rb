# encoding: utf-8

require "test/unit"

require "unicode_utils"

class TestUnicodeUtils < Test::Unit::TestCase

  def test_name
    assert_equal "LATIN SMALL LETTER F", UnicodeUtils.name("f")
    assert_equal Encoding::US_ASCII, UnicodeUtils.name("f").encoding
  end

  def test_simple_upcase
    assert_equal "ÜMIT", UnicodeUtils.simple_upcase("ümit")
    assert_equal "WEIß", UnicodeUtils.simple_upcase("weiß")
  end

  def test_simple_downcase
    assert_equal "ümit", UnicodeUtils.simple_downcase("ÜMIT")
    assert_equal "strasse", UnicodeUtils.simple_downcase("STRASSE")
  end

  def test_upcase
    assert_equal "WEISS 123", UnicodeUtils.upcase("Weiß 123")
    assert_equal "WEISS 123", UnicodeUtils.upcase("Weiß 123", :de)
    assert_equal "I", UnicodeUtils.upcase("i")
    assert_equal "I", UnicodeUtils.upcase("i", :de)
    assert_equal "\u{130}", UnicodeUtils.upcase("i", :tr)
    assert_equal "\u{130}", UnicodeUtils.upcase("i", :az)
  end

  def test_downcase
    # LATIN CAPITAL LETTER I WITH DOT ABOVE
    assert_equal "\u0069\u0307", UnicodeUtils.downcase("\u0130")
    assert_equal "\u0069\u0307", UnicodeUtils.downcase("\u0130", :de)
    assert_equal "\u0069", UnicodeUtils.downcase("\u0130", :tr)
    assert_equal "\u0069", UnicodeUtils.downcase("\u0130", :az)
  end

  def test_downcase_final_sigma
    assert_equal "abi\u{3c3}\u{df}\u{3c2}/\u{5ffff}\u{1042d}",
      UnicodeUtils.downcase("aBI\u{3a3}\u{df}\u{3a3}/\u{5ffff}\u{10405}")
  end

  def test_titlecase?
    assert_equal true, UnicodeUtils.titlecase_char?("\u{01F2}")
    assert_equal false, UnicodeUtils.titlecase_char?("\u{0041}")
  end

  def test_lowercase_char?
    assert_equal true, UnicodeUtils.lowercase_char?("c")
    assert_equal true, UnicodeUtils.lowercase_char?("ö")
    assert_equal false, UnicodeUtils.lowercase_char?("C")
    assert_equal false, UnicodeUtils.lowercase_char?("2")
  end

  def test_uppercase_char?
    assert_equal true, UnicodeUtils.uppercase_char?("C")
    assert_equal true, UnicodeUtils.uppercase_char?("Ö")
    assert_equal false, UnicodeUtils.uppercase_char?("2")
    assert_equal false, UnicodeUtils.uppercase_char?("c")
  end

  def test_cased_char?
    assert_equal true, UnicodeUtils.cased_char?("a")
    assert_equal true, UnicodeUtils.cased_char?("Ä")
    assert_equal true, UnicodeUtils.cased_char?("ß")
    assert_equal false, UnicodeUtils.cased_char?("2")
  end

  def test_case_ignorable_char?
    assert_equal true, UnicodeUtils.case_ignorable_char?(":")
    assert_equal true, UnicodeUtils.case_ignorable_char?("\u{302}")
    assert_equal true, UnicodeUtils.case_ignorable_char?("\u{20dd}")
    assert_equal true, UnicodeUtils.case_ignorable_char?("\u{600}")
    assert_equal true, UnicodeUtils.case_ignorable_char?("\u{2b0}")
    assert_equal true, UnicodeUtils.case_ignorable_char?("\u{2c2}")
    assert_equal false, UnicodeUtils.case_ignorable_char?("a")
    assert_equal false, UnicodeUtils.case_ignorable_char?("1")
  end

end
