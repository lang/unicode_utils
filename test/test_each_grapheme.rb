# -*- encoding: utf-8 -*-

require "test/unit"

require "unicode_utils/each_grapheme"

class TestEachGrapheme < Test::Unit::TestCase

  UNPAIRED_D800 = [0xd800]

  def each_grapheme_list(encoding = 'utf-8')
    count = 0
    skip_count = 0
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
        count += 1
        graphemes = line.split("÷").map(&:strip).delete_if(&:empty?)
        graphemes.map! { |g|
          cps = g.split("×").map(&:strip).delete_if(&:empty?).map { |c| c.to_i(16) }
          if cps == UNPAIRED_D800
            has_unpaired_surrogate = true
            skip_count += 1
            break
          end
          cps.inject(String.new.force_encoding(encoding), &:<<)
        }
        # Unpaired surrogates are not allowed in UTF-8
        # GraphemeBreakTest has test cases with unpaired surrogates
        yield graphemes unless has_unpaired_surrogate
      }
    end
    #print "\nSkipped #{skip_count} out of #{count} grapheme tests due to surrogates\n"
  end

  def test_each_grapheme_utf8
    c = 0
    each_grapheme_list { |grapheme_list|
      c += 1
      graphemes = []
      UnicodeUtils.each_grapheme(grapheme_list.join) { |g| graphemes << g }
      assert_equal grapheme_list, graphemes
    }
    assert_equal 348, c
  end

  def test_each_grapheme_utf16
    c = 0
    each_grapheme_list('utf-16le') { |grapheme_list|
      c += 1
      graphemes = []
      UnicodeUtils.each_grapheme(grapheme_list.join) { |g| graphemes << g }
      assert_equal grapheme_list, graphemes
    }
    # TODO: currently we skip the unpaired surrogates for UTF-16 also,
    # because current Ruby implementations raise an exception in
    # each_codepoint. Review this point with future implementations.
    assert_equal 348, c
  end

end
