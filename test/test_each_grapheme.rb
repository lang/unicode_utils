# -*- encoding: utf-8 -*-

require "test/unit"

require "unicode_utils/each_grapheme"

class TestEachGrapheme < Test::Unit::TestCase

  def each_grapheme_list
    fn = File.join(File.dirname(__FILE__),
                   "..", "data", "GraphemeBreakTest.txt")
    File.open(fn, "r:utf-8:-") do |input|
      input.each_line { |line|
        if line =~ /^([^#]*)#/
          line = $1
        end
        line.strip!
        next if line.empty?
        graphemes = line.split("÷").map(&:strip).delete_if(&:empty?)
        graphemes.map! { |g|
          cps = g.split("×").map(&:strip).delete_if(&:empty?).map { |c| c.to_i(16) }
          cps.inject(String.new.force_encoding('utf-8'), &:<<)
        }
        yield graphemes
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
