# encoding: utf-8

module UnicodeUtils

  module Impl # :nodoc:

    class ConditionalCasing

      attr_reader :mapping

      def initialize(mapping)
        @mapping = mapping
      end

      def context_match?(str, pos)
        true
      end

    end

    class NotBeforeDotConditionalCasing < ConditionalCasing

      def context_match?(str, post)
        # TODO
        false
      end

    end

    class MoreAboveConditionalCasing < ConditionalCasing

      def context_match?(str, post)
        # TODO
        false
      end

    end

    class AfterIConditionalCasing < ConditionalCasing

      def context_match?(str, pos)
        # TODO
        false
      end

    end

    class AfterSoftDottedConditionalCasing < ConditionalCasing

      def context_match?(str, pos)
        # TODO
        false
      end

    end

    class FinalSigmaConditionalCasing < ConditionalCasing

      def context_match?(str, pos)
        # TODO
        false
      end

    end

    def self.read_conditional_casings(filename)
      path = File.join(File.dirname(__FILE__), "..", "..", "cdata", filename)
      Hash.new.tap { |cp_map|
        File.open(path, "r:US-ASCII:-") do |input|
          input.each_line { |line|
            line.chomp!
            record = line.split(";")
            cp = record[0].to_i(16)
            mapping = record[1].split(",").map { |c| c.to_i(16) }
            language_id = record[2].empty? ? nil : record[2].to_sym
            context = record[3] && record[3].gsub('_', '')
            casing = Impl.const_get("#{context}ConditionalCasing").new(mapping)
            (cp_map[cp] ||= {})[language_id] = casing
          }
        end
      }
    end

    CONDITIONAL_UPCASE_MAP =
      read_conditional_casings("cond_uc_map")

    CONDITIONAL_DOWNCASE_MAP =
      read_conditional_casings("cond_lc_map")

    def self.conditional_upcase_mapping(cp, str, pos, language_id)
      lang_map = CONDITIONAL_UPCASE_MAP[cp]
      if lang_map
        casing = lang_map[language_id] || lang_map[nil]
        if casing && casing.context_match?(str, pos)
          casing.mapping
        end
      end
    end

    def self.conditional_downcase_mapping(cp, str, pos, language_id)
      lang_map = CONDITIONAL_DOWNCASE_MAP[cp]
      if lang_map
        casing = lang_map[language_id] || lang_map[nil]
        if casing && casing.context_match?(str, pos)
          casing.mapping
        end
      end
    end

  end

end
