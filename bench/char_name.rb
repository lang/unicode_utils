# -*- encoding: utf-8 -*-

require "benchmark"

require "unicode_utils/char_name"
require "unicode_utils/codepoint"

def all_char_names
  UnicodeUtils::Codepoint::RANGE.each { |codepoint|
    UnicodeUtils.char_name(codepoint)
  }
end

def cjk_char_names
  [0x3400..0x4DB5, 0x4E00..0x9FC3, 0x20000..0x2A6D6].each { |range|
    range.each { |codepoint|
      UnicodeUtils.char_name(codepoint)
    }
  }
end

def hangul_syllable_char_names
  (0xAC00..0xD7A3).each { |codepoint|
    UnicodeUtils.char_name(codepoint)
  }
end

def name_map_lookup(codepoint)
  UnicodeUtils::NAME_MAP[codepoint]
end

puts "UnicodeUtils.char_name benchmarks"

Benchmark.bm { |x|
  x.report("baseline") {
    UnicodeUtils::Codepoint::RANGE.each { |codepoint|
      name_map_lookup(codepoint)
    }
  }
  x.report("all codepoints") {
    all_char_names
  }
  x.report("CJK UNIFIED IDEOGRAPH") {
    cjk_char_names
  }
  x.report("HANGUL SYLLABLE") {
    hangul_syllable_char_names
  }
}
