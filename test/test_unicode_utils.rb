# encoding: utf-8

require "test/unit"

require "unicode_utils"

class TestUnicodeUtils < Test::Unit::TestCase

  def test_name
    assert_equal "LATIN SMALL LETTER F", UnicodeUtils.name("f")
  end

  def test_simple_upcase
    assert_equal "ÜMIT", UnicodeUtils.simple_upcase("ümit")
    assert_equal "WEIß", UnicodeUtils.simple_upcase("weiß")
  end

  def test_simple_downcase
    assert_equal "ümit", UnicodeUtils.simple_downcase("ÜMIT")
    assert_equal "strasse", UnicodeUtils.simple_downcase("STRASSE")
  end

end
