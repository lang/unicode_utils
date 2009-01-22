# -*- encoding: utf-8 -*-

require "unicode_utils/read_cdata"

module UnicodeUtils

  # Maps codepoints to integer codes. For the integer code to property
  # mapping, see #compile_word_break_property in data/compile.rb.
  WORD_BREAK_MAP =
    Impl.read_hexdigit_map("word_break_property") # :nodoc:

  # Split +str+ along word boundaries according to Unicode's Default
  # Word Boundary Specification, calling the given block with each
  # word. Returns +str+, or an enumerator if no block is given.
  #
  # Example:
  #
  #   UnicodeUtils.each_word("Hello, world!").to_a => ["Hello", ",", " ", "world", "!"]
  def each_word(str)
    return enum_for(__method__, str) unless block_given?
    cs = str.each_codepoint.map { |c| WORD_BREAK_MAP[c] }
    cs << nil << nil # for negative indices
    word = String.new.force_encoding(str.encoding)
    i = 0
    str.each_codepoint { |c|
      word << c
      if Impl::EachWord.word_break?(cs, i) && !word.empty?
        yield word
        word = String.new.force_encoding(str.encoding)
      end
      i += 1
    }
    yield word unless word.empty?
    str
  end
  module_function :each_word

  module Impl # :nodoc:all

    module EachWord

      def self.word_break?(cs, i)
        case
        when wb3(cs, i); false
        when wb3a(cs, i); true
        when wb3b(cs, i); true
        when wb5(cs, i); false
        when wb6(cs, i); false
        when wb7(cs, i); false
        when wb8(cs, i); false
        when wb9(cs, i); false
        when wb10(cs, i); false
        when wb11(cs, i); false
        when wb12(cs, i); false
        when wb13(cs, i); false
        when wb13a(cs, i); false
        when wb13b(cs, i); false
        else cs[i + 1] != 0x3 && cs[i + 1] != 0x4
        end
      end

      def self.skip_r(cs, i)
        loop {
          c = cs[i]
          break unless c == 0x3 || c == 0x4
          i += 1
        }
        i
      end

      def self.skip_l(cs, i)
        loop {
          c = cs[i]
          break unless c == 0x3 || c == 0x4
          i -= 1
        }
        i
      end

      def self.wb3(cs, i)
        cs[i] == 0x0 && cs[i + 1] == 0x1
      end

      def self.wb3a(cs, i)
        c = cs[i]
        c == 0x2 || c == 0x0 || c == 0x1
      end

      def self.wb3b(cs, i)
        c = cs[i + 1]
        c == 0x2 || c == 0x0 || c == 0x1
      end

      def self.wb5(cs, i)
        i0 = skip_l(cs, i)
        i1 = i + 1
        cs[i0] == 0x6 && cs[i1] == 0x6
      end

      def self.wb6(cs, i)
        i0 = skip_l(cs, i)
        i1 = i + 1
        i2 = skip_r(cs, i1 + 1)
        cs[i0] == 0x6 && (cs[i1] == 0x7 || cs[i1] == 0x9) && cs[i2] == 0x6
      end

      def self.wb7(cs, i)
        i0 = skip_l(cs, i)
        i_1 = skip_l(cs, i0 - 1) # i_1 = one _backwards_ from i0
        i1 = i + 1
        cs[i_1] == 0x6 && (cs[i0] == 0x7 || cs[i0] == 0x9) && cs[i1] == 0x6
      end

      def self.wb8(cs, i)
        i0 = skip_l(cs, i)
        i1 = i + 1
        cs[i0] == 0xA && cs[i1] == 0xA
      end

      def self.wb9(cs, i)
        i0 = skip_l(cs, i)
        i1 = i + 1
        cs[i0] == 0x6 && cs[i1] == 0xA
      end

      def self.wb10(cs, i)
        i0 = skip_l(cs, i)
        i1 = i + 1
        cs[i0] == 0xA && cs[i1] == 0x6
      end

      def self.wb11(cs, i)
        i0 = skip_l(cs, i)
        i_1 = skip_l(cs, i0 - 1)
        i1 = i + 1
        cs[i_1] == 0xA && (cs[i0] == 0x8 || cs[i0] == 0x9) && cs[i1] == 0xA
      end

      def self.wb12(cs, i)
        i0 = skip_l(cs, i)
        i1 = i + 1
        i2 = skip_r(cs, i1 + 1)
        cs[i0] == 0xA && (cs[i1] == 0x8 || cs[i1] == 0x9) && cs[i2] == 0xA
      end

      def self.wb13(cs, i)
        i0 = skip_l(cs, i)
        i1 = i + 1
        cs[i0] == 0x5 && cs[i1] == 0x5
      end

      def self.wb13a(cs, i)
        i0 = skip_l(cs, i)
        i1 = i + 1
        (cs[i0] == 0x6 || cs[i0] == 0xA || cs[i0] == 0x5 || cs[i0] == 0xB) && cs[i1] == 0xB
      end

      def self.wb13b(cs, i)
        i0 = skip_l(cs, i)
        i1 = i + 1
        cs[i0] == 0xB && (cs[i1] == 0x6 || cs[i1] == 0xA || cs[i1] == 0x5)
      end

    end

  end

end
