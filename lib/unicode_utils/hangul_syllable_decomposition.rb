# -*- encoding: utf-8 -*-

module UnicodeUtils

  # Derives the canonical decomposition of the given Hangul syllable.
  #
  # Example:
  #
  #     UnicodeUtils.hangul_syllable_decomposition("\u{d4db}") => "\u{1111}\u{1171}\u{11b6}"
  def hangul_syllable_decomposition(char)
    # constants
    sbase = 0xAC00
    lbase = 0x1100
    vbase = 0x1161
    tbase = 0x11A7
    scount = 11172
    lcount = 19
    vcount = 21
    tcount = 28
    ncount = vcount * tcount

    s = char.ord
    sindex = s - sbase
    if 0 <= sindex && sindex < scount
      l = lbase + sindex / ncount
      v = vbase + (sindex % ncount) / tcount
      t = tbase + sindex % tcount
      if t == tbase
        String.new.force_encoding(char.encoding) << l << v
      else
        String.new.force_encoding(char.encoding) << l << v << t
      end
    else
      char
    end
  end
  module_function :hangul_syllable_decomposition

end
