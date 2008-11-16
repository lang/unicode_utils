# -*- encoding: utf-8 -*-

require "unicode_utils/canonical_decomposition"
require "unicode_utils/combining_class"
require "unicode_utils/read_codepoint_set"

module UnicodeUtils
  
  COMPOSITION_EXCLUSION_SET = # :nodoc:
    Impl.read_codepoint_set("composition_exclusion_set")

  CANONICAL_COMPOSITION_MAP = Hash.new.tap do |m|
    CANONICAL_DECOMPOSITION_MAP.each_pair { |comp, decomp|
      if decomp.length == 2
        (m[decomp[0]] ||= {})[decomp[1]] = comp
      end
    }
  end

  module Impl
    
    module NFC

      def self.starter?(cp)
        (COMBINING_CLASS_MAP[cp] || 0) == 0
      end

      def self.nonstarter?(cp)
        !starter(cp)
      end

      # does b block c?
      def self.blocked?(b, c)
        # From the standard:
        # "If a combining character sequence is in canonical order,
        # then testing whether a character is blocked requires looking
        # at only the immediately preceding character."
        # cpary is in canonical order (since it comes out of
        # canonical_decomposition).
        (COMBINING_CLASS_MAP[b] || 0) >= (COMBINING_CLASS_MAP[c] || 0)
      end

      def self.primary_composite?(cp)
        unless CANONICAL_DECOMPOSITION_MAP[cp] ||
            # has hangul syllable decomposition?
            (cp >= 0xAC00 && cp <= 0xD7A3)
          return false
        end
        !COMPOSITION_EXCLUSION_SET.include?(cp)
      end

    end

  end

  def nfc(str)
    str = UnicodeUtils.canonical_decomposition(str)
    String.new.force_encoding(str.encoding).tap do |res|
      last_starter = nil
      uncomposable_non_starters = []
      str.each_codepoint { |cp|
        if Impl::NFC.starter?(cp)
          combined = false
          if last_starter && uncomposable_non_starters.empty?
            map = CANONICAL_COMPOSITION_MAP[last_starter]
            composition = map && map[cp]
            if composition && Impl::NFC.primary_composite?(composition)
              last_starter = composition
              combined = true
            end
          end
          unless combined
            res << last_starter if last_starter
            uncomposable_non_starters.each { |nc| res << nc }
            uncomposable_non_starters.clear
            last_starter = cp
          end
        else
          last_non_starter = uncomposable_non_starters.last
          if last_non_starter && Impl::NFC.blocked?(last_non_starter, cp)
            uncomposable_non_starters << cp
          else
            map = CANONICAL_COMPOSITION_MAP[last_starter]
            composition = map && map[cp]
            if composition && Impl::NFC.primary_composite?(composition)
              last_starter = composition
            else
              uncomposable_non_starters << cp
            end
          end
        end
      }
      res << last_starter if last_starter
      uncomposable_non_starters.each { |nc| res << nc }
    end
  end
  module_function :nfc

end
