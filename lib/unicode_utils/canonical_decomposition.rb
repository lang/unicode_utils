# -*- encoding: utf-8 -*-

require "unicode_utils/read_multivalued_map"
require "unicode_utils/hangul_syllable_decomposition"
require "unicode_utils/combining_class"

module UnicodeUtils

  CANONICAL_DECOMPOSITION_MAP =
    Impl.read_multivalued_map("canonical_decomposition_map") # :nodoc:
  
  # Get the canonical decomposition of the given string, also called
  # Normalization Form D or short NFD.
  #
  # The Unicode standard has multiple representations for some
  # characters. One representation as a single codepoint and other
  # representation(s) as a combination of multiple codepoints. This
  # function "decomposes" these characters in +str+ into the latter
  # representation.
  #
  # Example:
  #
  #   # LATIN SMALL LETTER A WITH ACUTE => LATIN SMALL LETTER A, COMBINING ACUTE ACCENT
  #   UnicodeUtils.canonical_decomposition("\u{E1}") => "\u{61}\u{301}"
  def canonical_decomposition(str)
    res = String.new.force_encoding(str.encoding)
    str.each_codepoint { |cp|
      if cp >= 0xAC00 && cp <= 0xD7A3 # hangul syllable
        Impl.append_hangul_syllable_decomposition(res, cp)
      else
        Impl.append_recursive_canonical_decomposition_mapping(res, cp)
      end
    }
    Impl.put_into_canonical_order(res)
  end
  module_function :canonical_decomposition

  module Impl # :nodoc:

    def self.append_recursive_canonical_decomposition_mapping(str, cp)
      mapping = CANONICAL_DECOMPOSITION_MAP[cp]
      if mapping
        mapping.each { |c|
          append_recursive_canonical_decomposition_mapping(str, c)
        }
      else
        str << cp
      end
    end

    def self.put_into_canonical_order(str)
      reorder_needed = false
      last_cp = nil
      str.each_codepoint { |cp|
        if last_cp
          cc = COMBINING_CLASS_MAP[cp] || 0
          if cc != 0
            if (COMBINING_CLASS_MAP[last_cp] || 0) > cc
              reorder_needed = true
              break
            end
          end
        end
        last_cp = cp
      }
      return str unless reorder_needed
      res = String.new.force_encoding(str.encoding)
      last_cp = nil
      str.each_codepoint { |cp|
        if last_cp
          cc = COMBINING_CLASS_MAP[cp] || 0
          if cc != 0 && (COMBINING_CLASS_MAP[last_cp] || 0) > cc
            res << cp
            cp = nil
          end
          res << last_cp
        end
        last_cp = cp
      }
      res << last_cp if last_cp
      put_into_canonical_order(res)
    end

  end

end
