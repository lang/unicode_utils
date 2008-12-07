# encoding: utf-8

require "test/unit"

require "unicode_utils/upcase"
require "unicode_utils/downcase"
require "unicode_utils/casefold"

class TestCaseMappings < Test::Unit::TestCase

  TXT_DIR = File.dirname(__FILE__)

  def read_txt(filename)
    File.read(File.join(TXT_DIR, filename), mode: "r:UTF-8:-")
  end

  def test_upcase_german_text
    assert_equal read_txt("dreilaendereck_uc.txt"),
      UnicodeUtils.upcase(read_txt("dreilaendereck.txt"))
  end

  def test_upcase_german_text_language_de
    assert_equal read_txt("dreilaendereck_uc.txt"),
      UnicodeUtils.upcase(read_txt("dreilaendereck.txt"), :de)
  end

  def test_upcase_german_text_language_tr
    assert_not_equal read_txt("dreilaendereck_uc.txt"),
      UnicodeUtils.upcase(read_txt("dreilaendereck.txt"), :tr)
  end

  def test_downcase_german_text
    assert_equal read_txt("dreilaendereck_lc.txt"),
      UnicodeUtils.downcase(read_txt("dreilaendereck.txt"))
  end

  def test_downcase_german_text_language_de
    assert_equal read_txt("dreilaendereck_lc.txt"),
      UnicodeUtils.downcase(read_txt("dreilaendereck.txt"), :de)
  end

  def test_downcase_german_text_language_tr
    assert_not_equal read_txt("dreilaendereck_lc.txt"),
      UnicodeUtils.downcase(read_txt("dreilaendereck.txt"), :tr)
  end

  def test_casefold_german_text
    assert_equal read_txt("dreilaendereck_cf.txt"),
      UnicodeUtils.casefold(read_txt("dreilaendereck.txt"))
  end

end
