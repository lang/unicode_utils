# encoding: utf-8

require "test/unit"

require "unicode_utils"

# Fast tests for allmost all UnicodeUtils functions.
class TestUnicodeUtils < Test::Unit::TestCase

  def test_name
    assert_equal "LATIN SMALL LETTER F", UnicodeUtils.char_name("f")
    assert_equal Encoding::US_ASCII, UnicodeUtils.char_name("f").encoding
    assert_equal nil, UnicodeUtils.char_name("\u{e000}") # private use
    assert_equal "<control>", UnicodeUtils.char_name("\t")
    assert_equal "CJK UNIFIED IDEOGRAPH-4E00", UnicodeUtils.char_name("\u{4e00}")
    assert_equal "CJK UNIFIED IDEOGRAPH-2A6D6", UnicodeUtils.char_name("\u{2a6d6}")
    assert_equal "CJK UNIFIED IDEOGRAPH-2A3D6", UnicodeUtils.char_name("\u{2a3d6}")
    assert_equal "HANGUL SYLLABLE PWILH", UnicodeUtils.char_name("\u{d4db}")
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
    assert_equal "ABI\u{3a3}SS\u{3a3}/FFI\u{5ffff}\u{10405}",
      UnicodeUtils.upcase("aBi\u{3c3}\u{df}\u{3c2}/\u{fb03}\u{5ffff}\u{1042d}")
    assert_equal "AB\u{130}\u{3a3}SS\u{3a3}/FFI\u{5ffff}\u{10405}",
      UnicodeUtils.upcase("aBi\u{3c3}\u{df}\u{3c2}/\u{fb03}\u{5ffff}\u{1042d}", :az)
    assert_equal "I\u{307}", UnicodeUtils.upcase("i\u{307}")
    assert_equal "I", UnicodeUtils.upcase("i\u{307}", :lt)
  end

  def test_downcase
    # LATIN CAPITAL LETTER I WITH DOT ABOVE
    assert_equal "\u0069\u0307", UnicodeUtils.downcase("\u0130")
    assert_equal "\u0069\u0307", UnicodeUtils.downcase("\u0130", :de)
    assert_equal "\u0069", UnicodeUtils.downcase("\u0130", :tr)
    assert_equal "\u0069", UnicodeUtils.downcase("\u0130", :az)
    assert_equal "ab\u{131}\u{3c3}\u{df}\u{3c2}/\u{5ffff}\u{1042d}",
      UnicodeUtils.downcase("aBI\u{3a3}\u{df}\u{3a3}/\u{5ffff}\u{10405}", :tr)
    # tests After_I and Not_Before_Dot
    assert_equal "abi", UnicodeUtils.downcase("aBI\u{307}", :tr)
    assert_equal "ia\u{300}", UnicodeUtils.downcase("Ia\u{300}", :lt)
    # this is probably unrealistic, because I don't understand a word Lithuanian
    assert_equal "i\u{307}\u{300}", UnicodeUtils.downcase("I\u{300}", :lt)
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

  def test_combining_class
    assert_equal 0, UnicodeUtils.combining_class("a")
    assert_equal 230, UnicodeUtils.combining_class("\u{1b6e}")
  end

  def test_soft_dotted_char?
    assert_equal true, UnicodeUtils.soft_dotted_char?("j")
    assert_equal true, UnicodeUtils.soft_dotted_char?("\u{2c7c}")
    assert_equal false, UnicodeUtils.soft_dotted_char?("a")
  end

  def test_hangul_syllable_decomposition
    assert_equal "\u{1111}\u{1171}\u{11b6}", UnicodeUtils.hangul_syllable_decomposition("\u{d4db}")
  end

  def test_jamo_short_name
    assert_equal "GG", UnicodeUtils.jamo_short_name("\u{1101}")
  end

  def test_canonical_decomposition
    assert_equal "\u{61}\u{301}",
      UnicodeUtils.canonical_decomposition("\u{E1}")
    assert_equal "\u{61}\u{301}\u{63}\u{327}\u{301}",
      UnicodeUtils.canonical_decomposition("\u{e1}\u{63}\u{301}\u{327}")
    assert_equal "\u{fb01}",
      UnicodeUtils.canonical_decomposition("\u{fb01}")
  end

  def test_nfd
    assert_equal "\u{61}\u{301}", UnicodeUtils.nfd("\u{E1}")
  end

  def test_canonical_equivalents?
    assert_equal true, UnicodeUtils.canonical_equivalents?("Äste", "A\u{308}ste")
    assert_equal false, UnicodeUtils.canonical_equivalents?("Äste", "Aste")
  end

  def test_nfc
    assert_equal "Häschen", UnicodeUtils.nfc("Ha\u{308}schen")
  end

  def test_compatibility_decomposition
    # the following two calls have the same results with
    # canonical_decomposition
    assert_equal "\u{61}\u{301}",
      UnicodeUtils.compatibility_decomposition("\u{E1}")
    assert_equal "\u{61}\u{301}\u{63}\u{327}\u{301}",
      UnicodeUtils.compatibility_decomposition("\u{e1}\u{63}\u{301}\u{327}")
    # this case differs from canonical decomposition
    assert_equal "\u{66}\u{69}",
      UnicodeUtils.compatibility_decomposition("\u{fb01}")
  end

  def test_nfkd
    assert_equal "\u{66}\u{69}", UnicodeUtils.nfkd("\u{fb01}")
  end

  def test_nfkc
    assert_equal "\u{66}\u{69}\u{e4}", UnicodeUtils.nfkc("\u{fb01}\u{e4}")
  end

  def test_simple_casefold
    assert_equal "abc123", UnicodeUtils.simple_casefold("ABC123")
    assert UnicodeUtils.simple_casefold("ÜMIT") ==
      UnicodeUtils.simple_casefold("ümit")
    assert UnicodeUtils.simple_casefold("WEISS") !=
      UnicodeUtils.simple_casefold("weiß")
  end

  def test_casefold
    assert_equal "abc123", UnicodeUtils.casefold("ABC123")
    assert UnicodeUtils.casefold("ÜMIT") ==
      UnicodeUtils.casefold("ümit")
    assert UnicodeUtils.casefold("WEISS") ==
      UnicodeUtils.casefold("weiß")
  end

  def test_each_grapheme
    graphemes = []
    UnicodeUtils.each_grapheme("word") { |g| graphemes << g }
    assert_equal ["w", "o", "r", "d"], graphemes
    UnicodeUtils.each_grapheme("") { |g| flunk }
    graphemes = []
    UnicodeUtils.each_grapheme("u\u{308}mit") { |g| graphemes << g }
    # diaeresis
    assert_equal ["u\u{308}", "m", "i", "t"], graphemes
    # hangul syllable
    graphemes = []
    UnicodeUtils.each_grapheme("\u{1111}\u{1171}\u{11b6}\u{d4db}") { |g| graphemes << g }
    assert_equal ["\u{1111}\u{1171}\u{11b6}", "\u{d4db}"], graphemes
    assert_equal ["a", "\r\n", "b"], UnicodeUtils.each_grapheme("a\r\nb").to_a
  end

  def test_each_word
    words = []
    UnicodeUtils.each_word("two words") { |w| words << w }
    assert_equal ["two", " ", "words"], words
    assert_equal ["a", " ", "b"], UnicodeUtils.each_word("a b").to_a
    assert_equal [" ", "b"], UnicodeUtils.each_word(" b").to_a
    assert_equal ["a", " "], UnicodeUtils.each_word("a ").to_a
    assert_equal [" "], UnicodeUtils.each_word(" ").to_a
    assert_equal ["a"], UnicodeUtils.each_word("a").to_a
    assert_equal [], UnicodeUtils.each_word("").to_a
    assert_equal ["Hello", ",", " ", "world", "!"],
      UnicodeUtils.each_word("Hello, world!").to_a
    assert_equal ["o\u{308}12"],
      UnicodeUtils.each_word("o\u{308}12").to_a
    assert_equal ["o\u{308}1"],
      UnicodeUtils.each_word("o\u{308}1").to_a
    assert_equal ["o\u{308}"],
      UnicodeUtils.each_word("o\u{308}").to_a
    assert_equal ["\u{308}", "o"],
      UnicodeUtils.each_word("\u{308}o").to_a
  end

  def test_titlecase
    assert_equal "Hello, World!", UnicodeUtils.titlecase("heLlo, world!")
    assert_equal "Find", UnicodeUtils.titlecase("ﬁnD")
    assert_equal "Ümit Huber Jandl", UnicodeUtils.titlecase("ümit huber jandl")
    assert_equal "İ Can Has 1Kg Cheesburger",
      UnicodeUtils.titlecase("i can has 1kg CHEESBURGER", :tr)
  end

end
