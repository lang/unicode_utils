# -*- encoding: utf-8 -*-

require "unicode_utils/read_cdata"

module UnicodeUtils

  # Maps codepoints to integer codes. For the integer code to property
  # mapping, see #compile_word_break_property in data/compile.rb.
  WORD_BREAK_MAP =
    Impl.read_hexdigit_map_ranges("word_break_property") # :nodoc:

  module Impl

    module EW

      def self.char_class(ranges)
        "[" <<
          ranges.map { |r|
            if r.begin == r.end
                "\\u{#{r.begin.to_s(16)}}"
            else
                "\\u{#{r.begin.to_s(16)}}-\\u{#{r.end.to_s(16)}}"
            end
          }.join << "]"
      end

      CR = char_class(WORD_BREAK_MAP[0x0])
      LF = char_class(WORD_BREAK_MAP[0x1])
      Newline = char_class(WORD_BREAK_MAP[0x2])
      Extend = char_class(WORD_BREAK_MAP[0x3])
      Format = char_class(WORD_BREAK_MAP[0x4])
      Katakana = char_class(WORD_BREAK_MAP[0x5])
      ALetter = char_class(WORD_BREAK_MAP[0x6])
      MidLetter = char_class(WORD_BREAK_MAP[0x7])
      MidNum = char_class(WORD_BREAK_MAP[0x8])
      MidNumLet = char_class(WORD_BREAK_MAP[0x9])
      Numeric = char_class(WORD_BREAK_MAP[0xA])
      ExtendNumLet = char_class(WORD_BREAK_MAP[0xB])
      
    end

  end

  def each_word(str)
    return enum_for(__method__, str) unless block_given?
    c0 = nil
    c0_prop = nil
    c1 = nil
    c1_prop = nil
    c2 = nil
    c2_prop = nil
    word = String.new.force_encoding(str.encoding)
    # looking for break between c1 and c2
    str.each_codepoint { |c|
      c_prop = WORD_BREAK_MAP[c]
      wbreak = Impl.word_break?(c0_prop, c1_prop, c2_prop, c_prop)
      if wbreak == :ignore
        word << c2 if c2
        c2 = c
        c2_prop = c_prop
        next
      end
      if wbreak && !word.empty?
        yield word
        word = String.new.force_encoding(str.encoding)
      end
      word << c2 if c2
      c0 = c1
      c0_prop = c1_prop
      c1 = c2
      c1_prop = c2_prop
      c2 = c
      c2_prop = c_prop
    }
    wbreak = Impl.word_break?(c0_prop, c1_prop, c2_prop, nil)
    if wbreak == true && !word.empty?
      yield word
      word = String.new.force_encoding(str.encoding)
    end
    word << c2 if c2
    yield word unless word.empty?
  end
  module_function :each_word

  module Impl
    
    def self.word_break?(c0_prop, c1_prop, c2_prop, c_prop)
      if c1_prop == 0x0 && c2_prop == 0x1
        # don't break CR LF
        return false
      elsif c1_prop == 0x2 || c1_prop == 0x0 || c1_prop == 0x1
        # break after newline
        return true
      elsif c2_prop == 0x2 || c1_prop == 0x0 || c1_prop == 0x1
        # break before newline
        return true
      elsif c2_prop == 0x3 || c2_prop == 0x4
        # ignore format/extend characters except at start/end
        return :ignore
      elsif c1_prop == 0x6 && c2_prop == 0x6
        # don't break between most letters
        return false
      elsif c1_prop == 0x6 &&
            ((c2_prop == 0x7 || c2_prop == 0x9) && c_prop == 0x6)
        # don't break letters across certain punctuation
        return false
      elsif (c0_prop == 0x6 && (c1_prop == 0x7 || c1_prop == 0x9)) &&
            c2_prop == 0x6
        # don't break letters across certain punctuation
        return false
      elsif c1_prop == 0xA && c2_prop == 0xA
        # don't break within sequences of digits
        return false
      elsif c1_prop == 0x6 && c2_prop == 0xA
        # don't break digits adjacent to letters
        return false
      elsif c1_prop == 0xA && c2_prop == 0x6
        # don't break digits adjacent to letters
        return false
      elsif (c0_prop == 0xA && (c1_prop == 0x8 || c1_prop == 0x9)) &&
            c2_prop == 0xA
        # don't break certain digits across certain punctuation
        return false
      elsif c1_prop == 0xA &&
            ((c2_prop == 0x8 || c2_prop == 0x9) && c_prop == 0xA)
        # don't break certain digits across certain punctuation
        return false
      elsif c1_prop == 0x5 && c2_prop == 0x5
        # don't break between katakana
        return false
      elsif (c1_prop == 0x6 || c1_prop == 0xA || c1_prop == 0x5 || c1_prop == 0xB) &&
            c2_prop == 0xB
        # don't break from extenders
        return false
      elsif c1_prop == 0xB &&
            (c2_prop == 0x6 || c2_prop == 0xA || c2_prop == 0x5)
        # don't break from extenders
        return false
      else
        # break everywhere
        return true
      end
    end

  end

end
