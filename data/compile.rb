# encoding: utf-8

module UnicodeUtils

  class DecompositionMapping

    attr_accessor :tag, :mapping

    def initialize
      @tag = nil
      @mapping = nil
    end

    def canonical?
      @tag.nil?
    end

    def compatibility?
      !canonical?
    end

  end

  Codepoint = Struct.new(:codepoint,
                         :name,
                         :general_category,
                         :decomposition_mapping,
                         :simple_lowercase_mapping,
                         :simple_uppercase_mapping,
                         :simple_titlecase_mapping)

  class SpecialCasing

    attr_accessor :codepoint,
                  :uppercase_mapping,
                  :lowercase_mapping,
                  :titlecase_mapping,
                  :conditions

    def initialize
      @codepoint = nil
      @uppercase_mapping = nil
      @lowercase_mapping = nil
      @titlecase_mapping = nil
      @conditions = nil
    end

    def has_lowercase?
      conditional? ||
        @lowercase_mapping.length != 1 ||
        @lowercase_mapping.first != @codepoint
    end

    def has_uppercase?
      conditional? ||
        @uppercase_mapping.length != 1 ||
        @uppercase_mapping.first != @codepoint
    end

    def has_titlecase?
      conditional? ||
        @titlecase_mapping.length != 1 ||
        @titlecase_mapping.first != @codepoint
    end

    def language
      # The current Unicode standard has at most one language condition
      # per special casing. Might change in a future standard.
      @conditions.find { |c| language_condition?(c)  }
    end

    def context
      # The current Unicode standard has at most one context condition
      # per special casing. Might change in a future standard.
      @conditions.find { |c| !language_condition?(c) }
    end

    def conditional?
      !@conditions.empty?
    end

    private

    def language_condition?(condition)
      condition =~ /^[a-z]+$/
    end

  end

  Property = Struct.new(:codepoint,
                        :property)

  CasefoldMapping = Struct.new(:codepoint,
                               :status,
                               :mapping)

  class Compiler

    def initialize
      @basedir =
        File.absolute_path(File.join(File.dirname(__FILE__), ".."))
      @datadir = File.join(@basedir, "data")
      @cdatadir = File.join(@basedir, "cdata")
    end

    def each_codepoint
      data_fn = File.join(@datadir, "UnicodeData.txt")
      File.open(data_fn, "r:US-ASCII") do |io|
        io.each_line { |line|
          yield parse_line(line)
        }
      end
      nil
    end

    def parse_line(line)
      Codepoint.new.tap { |cp|
        fields = line.chomp.split(";")
        cp.codepoint = fields[0].to_i(16)
        cp.name = fields[1]
        cp.general_category = fields[2]
        unless fields[5].empty?
          dm = DecompositionMapping.new
          parts = fields[5].split(/\s+/)
          if parts.first =~ /^<.*>$/
            dm.tag = parts.shift
          end
          dm.mapping = parts.map { |p| p.to_i(16) }
          cp.decomposition_mapping = dm
        end
        uc_mapping = fields[12]
        unless uc_mapping.nil? || uc_mapping.empty?
          cp.simple_uppercase_mapping = uc_mapping.to_i(16)
        end
        lc_mapping = fields[13]
        unless lc_mapping.nil? || lc_mapping.empty?
          cp.simple_lowercase_mapping = lc_mapping.to_i(16)
        end
        tc_mapping = fields[14]
        unless tc_mapping.nil? || tc_mapping.empty?
          cp.simple_titlecase_mapping = tc_mapping.to_i(16)
        end
      }
    end

    def each_special_casing
      data_fn = File.join(@datadir, "SpecialCasing.txt")
      File.open(data_fn, "r:US-ASCII") do |input|
        each_significant_line(input) { |line|
          yield parse_special_casing_line(line)
        }
      end
    end

    def parse_special_casing_line(line)
      SpecialCasing.new.tap { |sc|
        fields = line.split(";").map(&:strip)
        sc.codepoint = fields[0].to_i(16)
        sc.lowercase_mapping = fields[1].split(" ").map { |x| x.to_i(16) }
        sc.titlecase_mapping = fields[2].split(" ").map { |x| x.to_i(16) }
        sc.uppercase_mapping = fields[3].split(" ").map { |x| x.to_i(16) }
        if fields[4]
          sc.conditions = fields[4].split(" ")
        else
          sc.conditions = []
        end
      }
    end

    def each_property(filename, opts = {flatten_ranges: true})
      data_fn = File.join(@datadir, filename)
      File.open(data_fn, "r:US-ASCII") do |input|
        each_significant_line(input) { |line|
          fields = line.split(";").map(&:strip)
          property = fields[1]
          if fields[0] =~ /^([\dA-F]+)\.{2}([\dA-F]+)$/ # codepoint-range?
            range = Range.new($1.to_i(16), $2.to_i(16))
            if opts[:flatten_ranges]
              range.each { |cp| yield Property.new(cp, property) }
            else
              yield Property.new(range, property)
            end
          else
            yield Property.new(fields[0].to_i(16), property)
          end
        }
      end
    end

    def each_casefold_mapping
      path = File.join(@datadir, "CaseFolding.txt")
      File.open(path, "r:UTF-8") do |input|
        each_significant_line(input) { |line|
          fields = line.split(";").map(&:strip)
          raise unless fields[0] =~ /^[0-9A-F]+$/
          yield CasefoldMapping.new(
            fields[0].to_i(16),
            fields[1],
            fields[2].split(" ").map { |c| c.to_i(16) }
          )
        }
      end
    end

    def compile_unicode_data
      uc_file =
        File.open(File.join(@cdatadir, "simple_uc_map"), "w:US-ASCII")
      lc_file =
        File.open(File.join(@cdatadir, "simple_lc_map"), "w:US-ASCII")
      tc_file =
        File.open(File.join(@cdatadir, "simple_tc_map"), "w:US-ASCII")
      name_file =
        File.open(File.join(@cdatadir, "names"), "w:US-ASCII")
      cat_set_titlecase_file =
        File.open(File.join(@cdatadir, "cat_set_titlecase"), "w:US-ASCII")
      canonical_dm_file =
        File.open(File.join(@cdatadir, "canonical_decomposition_map"), "w:US-ASCII")
      compatibility_dm_file =
        File.open(File.join(@cdatadir, "compatibility_decomposition_map"), "w:US-ASCII")
      general_category_ranges_file =
        File.open(File.join(@cdatadir, "general_category_ranges"), "w:US-ASCII")
      general_category_per_cp_file =
        File.open(File.join(@cdatadir, "general_category_per_cp"), "w:US-ASCII")
      begin
        current_range_name = nil
        current_range_first = nil
        each_codepoint { |cp|
          if cp.simple_uppercase_mapping
            uc_file.write(format_codepoint(cp.codepoint))
            uc_file.write(format_codepoint(cp.simple_uppercase_mapping))
          end
          if cp.simple_lowercase_mapping
            lc_file.write(format_codepoint(cp.codepoint))
            lc_file.write(format_codepoint(cp.simple_lowercase_mapping))
          end
          if cp.simple_titlecase_mapping
            tc_file.write(format_codepoint(cp.codepoint))
            tc_file.write(format_codepoint(cp.simple_titlecase_mapping))
          end
          if cp.general_category == "Lt"
            cat_set_titlecase_file.write(format_codepoint(cp.codepoint))
          end
          if cp.name =~ /^<([^,]+), (First|Last)>$/
            case $2
            when "First"
              raise "range error" if current_range_name || current_range_first
              current_range_name = $1
              current_range_first = cp.codepoint
            when "Last"
              raise "range error" if current_range_name != $1
              general_category_ranges_file.write(format_codepoint(current_range_first))
              general_category_ranges_file.write(format_codepoint(cp.codepoint))
              raise cp.general_category unless cp.general_category.bytesize == 2
              general_category_ranges_file.write(cp.general_category)
              current_range_name = nil
              current_range_first = nil
            else raise $2
            end
          else
            name_file.write(format_codepoint(cp.codepoint))
            name_file.puts(cp.name)
            raise cp.general_category unless cp.general_category.bytesize == 2
            general_category_per_cp_file.write(format_codepoint(cp.codepoint))
            general_category_per_cp_file.write(cp.general_category)
          end
          if cp.decomposition_mapping
            if cp.decomposition_mapping.canonical?
              canonical_dm_file.write(format_codepoint(cp.codepoint))
              cp.decomposition_mapping.mapping.each { |c|
                canonical_dm_file.write(format_codepoint(c))
              }
              canonical_dm_file.write("x" * 6) # end of entry marker
            elsif cp.decomposition_mapping.compatibility?
              compatibility_dm_file.write(format_codepoint(cp.codepoint))
              cp.decomposition_mapping.mapping.each { |c|
                compatibility_dm_file.write(format_codepoint(c))
              }
              compatibility_dm_file.write("x" * 6) # end of entry marker
            end
          end
        }
      ensure
        uc_file.close
        lc_file.close
        tc_file.close
        name_file.close
        cat_set_titlecase_file.close
        canonical_dm_file.close
        compatibility_dm_file.close
      end
    end

    def compile_special_casing
      uc_file =
        File.open(File.join(@cdatadir, "special_uc_map"), "w:US-ASCII")
      lc_file =
        File.open(File.join(@cdatadir, "special_lc_map"), "w:US-ASCII")
      tc_file =
        File.open(File.join(@cdatadir, "special_tc_map"), "w:US-ASCII")
      cond_uc_file =
        File.open(File.join(@cdatadir, "cond_uc_map"), "w:US-ASCII")
      cond_lc_file =
        File.open(File.join(@cdatadir, "cond_lc_map"), "w:US-ASCII")
      cond_tc_file =
        File.open(File.join(@cdatadir, "cond_tc_map"), "w:US-ASCII")
      begin
        each_special_casing { |sc|
          if sc.conditional?
            # format: codepoint;[mapped_codepoint1,...];[language_id];[context]
            if sc.has_uppercase?
              cond_uc_file.write(format_codepoint(sc.codepoint))
              cond_uc_file.write(";")
              cond_uc_file.write(
                sc.uppercase_mapping.map { |c| format_codepoint(c) }.join(","))
              cond_uc_file.write(";")
              cond_uc_file.write(sc.language || "")
              cond_uc_file.write(";")
              cond_uc_file.write(sc.context || "")
              cond_uc_file.puts
            end
            if sc.has_lowercase?
              cond_lc_file.write(format_codepoint(sc.codepoint))
              cond_lc_file.write(";")
              cond_lc_file.write(
                sc.lowercase_mapping.map { |c| format_codepoint(c) }.join(","))
              cond_lc_file.write(";")
              cond_lc_file.write(sc.language || "")
              cond_lc_file.write(";")
              cond_lc_file.write(sc.context || "")
              cond_lc_file.puts
            end
            if sc.has_titlecase?
              cond_tc_file.write(format_codepoint(sc.codepoint))
              cond_tc_file.write(";")
              cond_tc_file.write(
                sc.titlecase_mapping.map { |c| format_codepoint(c) }.join(","))
              cond_tc_file.write(";")
              cond_tc_file.write(sc.language || "")
              cond_tc_file.write(";")
              cond_tc_file.write(sc.context || "")
              cond_tc_file.puts
            end
          else
            if sc.has_uppercase?
              uc = sc.uppercase_mapping
              uc_file.write(format_codepoint(sc.codepoint))
              uc.each { |cp|
                uc_file.write(format_codepoint(cp))
              }
              uc_file.write("x" * 6) # end of entry marker
            end
            if sc.has_lowercase?
              lc = sc.lowercase_mapping
              lc_file.write(format_codepoint(sc.codepoint))
              lc.each { |cp|
                lc_file.write(format_codepoint(cp))
              }
              lc_file.write("x" * 6)
            end
            if sc.has_titlecase?
              tc = sc.titlecase_mapping
              tc_file.write(format_codepoint(sc.codepoint))
              tc.each { |cp|
                tc_file.write(format_codepoint(cp))
              }
              tc_file.write("x" * 6)
            end
          end
        }
      ensure
        uc_file.close
        lc_file.close
        tc_file.close
        cond_uc_file.close
        cond_lc_file.close
        cond_tc_file.close
      end
      sort_file(File.join(@cdatadir, "cond_uc_map"))
      sort_file(File.join(@cdatadir, "cond_lc_map"))
    end

    def compile_derived_core_properties
      uc_file =
        File.open(File.join(@cdatadir, "prop_set_uppercase"), "w:US-ASCII")
      lc_file =
        File.open(File.join(@cdatadir, "prop_set_lowercase"), "w:US-ASCII")
      di_file =
        File.open(File.join(@cdatadir, "prop_set_default_ignorable"), "w:US-ASCII")
      begin
        each_property("DerivedCoreProperties.txt") { |dcp|
          case dcp.property
          when "Uppercase"
            uc_file.write(format_codepoint(dcp.codepoint))
          when "Lowercase"
            lc_file.write(format_codepoint(dcp.codepoint))
          when "Default_Ignorable_Code_Point"
            di_file.write(format_codepoint(dcp.codepoint))
          end
        }
      ensure
        uc_file.close
        lc_file.close
        di_file.close
      end
    end

    def compile_property_value_aliases
      gc_file =
        File.open(File.join(@cdatadir, "general_category_aliases"), "w:US-ASCII")
      begin
        data_fn = File.join(@datadir, "PropertyValueAliases.txt")
        File.open(data_fn, "r:US-ASCII") do |input|
          each_significant_line(input) { |line|
            fields = line.split(";").map(&:strip)
            case fields[0]
            when "gc"
              gc_file.puts "#{fields[1]};#{fields[2]}"
            end
          }
        end
      ensure
        gc_file.close
      end
    end

    def compile_case_ignorable_set
      # See Section 3.13, Unicode 5.0
      path = File.join(@cdatadir, "case_ignorable_set")
      File.open(path, "w:US-ASCII") do |output|
        each_property("WordBreakProperty.txt") { |prop|
          if prop.property == "MidLetter"
            output.write(format_codepoint(prop.codepoint))
          end
        }
        each_codepoint { |cp|
          if cp.general_category =~ /^(Mn|Me|Cf|Lm|Sk)$/
            output.write(format_codepoint(cp.codepoint))
          end
        }
      end
    end

    def compile_combining_class
      path = File.join(@cdatadir, "combining_class_map")
      File.open(path, "w:US-ASCII") do |output|
        each_property("DerivedCombiningClass.txt") { |prop|
          class_int = prop.property.to_i
          next if class_int == 0 # default value
          output.write(format_codepoint(prop.codepoint))
          # class_int is a value in range 0..255
          # two hex-digits are enough
          output.write(sprintf("%02x", class_int))
        }
      end
    end

    def compile_soft_dotted_set
      path = File.join(@cdatadir, "soft_dotted_set")
      File.open(path, "w:US-ASCII") do |output|
        each_property("PropList.txt") { |prop|
          if prop.property == "Soft_Dotted"
            output.write(format_codepoint(prop.codepoint))
          end
        }
      end
    end

    def compile_jamo_short_names
      path = File.join(@cdatadir, "jamo_short_names")
      File.open(path, "w:US-ASCII") do |output|
        each_property("Jamo.txt") { |prop|
          if prop.property
            output.write(format_codepoint(prop.codepoint))
            output.puts(prop.property)
          end
        }
      end
    end

    def compile_composition_exclusion_set
      path = File.join(@cdatadir, "composition_exclusion_set")
      File.open(path, "w:US-ASCII") do |output|
        each_property("DerivedNormalizationProps.txt") { |prop|
          if prop.property == "Full_Composition_Exclusion"
            output.write(format_codepoint(prop.codepoint))
          end
        }
      end
    end

    def compile_casefold_mappings
      c_file =
        File.open(File.join(@cdatadir, "casefold_c_map"), "w:US-ASCII")
      f_file =
        File.open(File.join(@cdatadir, "casefold_f_map"), "w:US-ASCII")
      s_file =
        File.open(File.join(@cdatadir, "casefold_s_map"), "w:US-ASCII")
      begin
        each_casefold_mapping { |mapping|
          case mapping.status
          when "C"
            raise unless mapping.mapping.size == 1
            c_file.write(format_codepoint(mapping.codepoint))
            c_file.write(format_codepoint(mapping.mapping.first))
          when "S"
            raise unless mapping.mapping.size == 1
            s_file.write(format_codepoint(mapping.codepoint))
            s_file.write(format_codepoint(mapping.mapping.first))
          when "F"
            f_file.write(format_codepoint(mapping.codepoint))
            mapping.mapping.each { |cp|
              f_file.write(format_codepoint(cp))
            }
            f_file.write("x" * 6) # end of entry marker
          when "T"
            # this is not required by the Unicode standard, we
            # don't implement it for now
          end
        }
      ensure
        c_file.close
        f_file.close
        s_file.close
      end
    end

    def compile_grapheme_break_property
      props = {"CR" => 0x0,
               "LF" => 0x1,
               "Control" => 0x2,
               "Extend" => 0x3,
               "Prepend" => 0x4,
               "SpacingMark" => 0x5,
               "L" => 0x6,
               "V" => 0x7,
               "T" => 0x8,
               "LV" => 0x9,
               "LVT" => 0xA}
      filename = File.join(@cdatadir, "grapheme_break_property")
      File.open(filename, "w:us-ascii") do |output|
        each_property("GraphemeBreakProperty.txt") { |prop|
          i = props[prop.property] ||
            raise("unknown property value #{prop.property}")
          digit = i.to_s(16)
          raise unless digit.length == 1
          output.write(format_codepoint(prop.codepoint))
          output.write(digit)
        }
      end
    end

    def compile_word_break_property
      props = {"CR" => 0x0,
               "LF" => 0x1,
               "Newline" => 0x2,
               "Extend" => 0x3,
               "Format" => 0x4,
               "Katakana" => 0x5,
               "ALetter" => 0x6,
               "MidLetter" => 0x7,
               "MidNum" => 0x8,
               "MidNumLet" => 0x9,
               "Numeric" => 0xA,
               "ExtendNumLet" => 0xB}
      filename = File.join(@cdatadir, "word_break_property")
      File.open(filename, "w:us-ascii") do |output|
        each_property("WordBreakProperty.txt") { |prop|
          i = props[prop.property] ||
            raise("unknown property value #{prop.property}")
          digit = i.to_s(16)
          raise unless digit.length == 1
          output.write(format_codepoint(prop.codepoint))
          output.write(digit)
        }
      end
    end

    def compile_east_asian_width_property
      # must be in sync with EAST_ASIAN_SYMBOL_MAP in read_cdata.rb
      # "N" is default, and not written to the cdata file
      props = {"A" => 0x1,
               "H" => 0x2,
               "W" => 0x3,
               "F" => 0x4,
               "Na" => 0x5}
      range_props = []
      per_cp_file =
        File.open(File.join(@cdatadir, "east_asian_width_property_per_cp"),
                  "w:us-ascii")
      range_file =
        File.open(File.join(@cdatadir, "east_asian_width_property_ranges"),
                  "w:us-ascii")
      each_property("EastAsianWidth.txt", flatten_ranges: false) { |prop|
        next if prop.property == "N"
        i = props[prop.property] ||
          raise("unknown property value #{prop.property}")
        if prop.codepoint.kind_of?(Range)
          range_props << prop
        else
          per_cp_file.write(format_codepoint(prop.codepoint))
          per_cp_file.write(i.to_s(16))
        end
      }
      range_props.sort_by! { |rp| rp.codepoint.begin }
      # try to join ranges
      range_props2 = []
      range_props.each { |rp|
        if range_props2.empty?
          range_props2 << rp
        else
          previous = range_props2.last
          if previous.codepoint.end.succ == rp.codepoint.begin &&
              previous.property == rp.property
            previous.codepoint =
              Range.new(previous.codepoint.begin, rp.codepoint.end)
          else
            range_props2 << rp
          end
        end
      }
      range_props2.each { |rp|
        i = props[rp.property] ||
          raise("unknown property value #{prop.property}")
        # flatten small ranges
        if (rp.codepoint.end - rp.codepoint.begin) <= 100
          rp.codepoint.begin.upto(rp.codepoint.end) { |cp|
            per_cp_file.write(format_codepoint(cp))
            per_cp_file.write(i.to_s(16))
          }
        else
          range_file.write(format_codepoint(rp.codepoint.begin))
          range_file.write(format_codepoint(rp.codepoint.end))
          range_file.write(i.to_s(16))
        end
      }
      per_cp_file.close
      range_file.close
    end

    def run
      compile_unicode_data
      compile_special_casing
      compile_derived_core_properties
      compile_case_ignorable_set
      compile_combining_class
      compile_soft_dotted_set
      compile_jamo_short_names
      compile_composition_exclusion_set
      compile_casefold_mappings
      compile_grapheme_break_property
      compile_word_break_property
      compile_east_asian_width_property
      compile_property_value_aliases
    end

    def format_codepoint(cp)
      sprintf("%06x", cp)
    end

    def each_significant_line(io)
        io.each_line { |line|
          if line =~ /^([^#]*)#/
            line = $1 || ""
          end
          line.strip!
          yield(line) unless line.empty?
        }
    end

    def sort_file(path)
      lines = File.open(path, "rb") do |io| io.readlines end
      lines.sort!
      File.open(path, "wb") do |io|
        lines.each { |line| io.print line }
      end
    end

  end

end

if $0 == __FILE__
  UnicodeUtils::Compiler.new.run
end
