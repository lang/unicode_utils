# -*- encoding: utf-8 -*-

require "test/unit"

require "unicode_utils/each_grapheme"

class TestEachGrapheme < Test::Unit::TestCase

  UNPAIRED_D800 = [0xd800]

  def each_grapheme_list
    fn = File.join(File.dirname(__FILE__),
                   "..", "data", "GraphemeBreakTest.txt")
    File.open(fn, "r:utf-8:-") do |input|
      input.each_line { |line|
        has_unpaired_surrogate = false
        if line =~ /^([^#]*)#/
          line = $1
        end
        line.strip!
        next if line.empty?
        graphemes = line.split("÷").map(&:strip).delete_if(&:empty?)
        graphemes.map! { |g|
          cps = g.split("×").map(&:strip).delete_if(&:empty?).map { |c| c.to_i(16) }
          has_unpaired_surrogate = true if cps == UNPAIRED_D800
          cps.inject(String.new.force_encoding('utf-8'), &:<<)
        }
        # Unpaired surrogates are not allowed in UTF-8
        # GraphemeBreakTest has test cases with unpaired surrogates which Ruby
        # 1.9.3 rightfully refuses to iterate with each_codepoint.
        yield graphemes unless has_unpaired_surrogate
      }
    end
  end

  def test_each_grapheme
    c = 0
    each_grapheme_list { |grapheme_list|
      c += 1
      graphemes = []
      UnicodeUtils.each_grapheme(grapheme_list.join) { |g| graphemes << g }
      assert_equal grapheme_list, graphemes
    }
    assert_equal 288, c
  end

end
