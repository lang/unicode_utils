# -*- encoding: utf-8 -*-

require "test/unit"

require "unicode_utils/each_word"

class TestEachWord < Test::Unit::TestCase

  def each_word_list
    fn = File.join(File.dirname(__FILE__),
                   "..", "data", "WordBreakTest.txt")
    File.open(fn, "r:utf-8:-") do |input|
      input.each_line { |line|
        if line =~ /^([^#]*)#/
          line = $1
        end
        line.strip!
        next if line.empty?
        words = line.split("÷").map(&:strip).delete_if(&:empty?)
        words.map! { |w|
          cps = w.split("×").map(&:strip).delete_if(&:empty?).map { |c| c.to_i(16) }
          cps.inject(String.new.force_encoding('utf-8'), &:<<)
        }
        yield words
      }
    end
  end

  def test_each_word
    c = 0
    each_word_list { |word_list|
      c += 1
      words = UnicodeUtils.each_word(word_list.join).to_a
      assert_equal word_list, words
    }
  end

end
