# encoding: utf-8

module UnicodeUtils

  Codepoint = Struct.new(:codepoint,
                         :name,
                         :general_category,
                         :simple_lowercase_mapping,
                         :simple_uppercase_mapping)

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

  DerivedCoreProperty = Struct.new(:codepoint,
                                   :property)

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
        fields = line.split(";")
        cp.codepoint = fields[0].to_i(16)
        cp.name = fields[1]
        cp.general_category = fields[2]
        uc_mapping = fields[12]
        unless uc_mapping.empty?
          cp.simple_uppercase_mapping = uc_mapping.to_i(16)
        end
        lc_mapping = fields[13]
        unless lc_mapping.empty?
          cp.simple_lowercase_mapping = lc_mapping.to_i(16)
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

    def each_derived_core_property
      data_fn = File.join(@datadir, "DerivedCoreProperties.txt")
      File.open(data_fn, "r:US-ASCII") do |input|
        each_significant_line(input) { |line|
          fields = line.split(";").map(&:strip)
          property = fields[1]
          if fields[0] =~ /^([\dA-F]+)\.{2}([\dA-F]+)$/ # codepoint-range?
            $1.to_i(16).upto($2.to_i(16)) { |cp|
              yield DerivedCoreProperty.new(cp, property)
            }
          else
            yield DerivedCoreProperty.new(fields[0].to_i(16), property)
          end
        }
      end
    end

    def compile_unicode_data
      uc_file =
        File.open(File.join(@cdatadir, "simple_uc_map"), "w:US-ASCII")
      lc_file =
        File.open(File.join(@cdatadir, "simple_lc_map"), "w:US-ASCII")
      name_file =
        File.open(File.join(@cdatadir, "names"), "w:US-ASCII")
      cat_set_titlecase_file =
        File.open(File.join(@cdatadir, "cat_set_titlecase"), "w:US-ASCII")
      begin
        each_codepoint { |cp|
          if cp.simple_uppercase_mapping
            uc_file.write(format_codepoint(cp.codepoint))
            uc_file.write(format_codepoint(cp.simple_uppercase_mapping))
          end
          if cp.simple_lowercase_mapping
            lc_file.write(format_codepoint(cp.codepoint))
            lc_file.write(format_codepoint(cp.simple_lowercase_mapping))
          end
          if cp.general_category == "Lt"
            cat_set_titlecase_file.write(format_codepoint(cp.codepoint))
          end
          name_file.write(format_codepoint(cp.codepoint))
          name_file.puts(cp.name)
        }
      ensure
        uc_file.close
        lc_file.close
        name_file.close
        cat_set_titlecase_file.close
      end
    end

    def compile_special_casing
      uc_file =
        File.open(File.join(@cdatadir, "special_uc_map"), "w:US-ASCII")
      lc_file =
        File.open(File.join(@cdatadir, "special_lc_map"), "w:US-ASCII")
      cond_uc_file =
        File.open(File.join(@cdatadir, "cond_uc_map"), "w:US-ASCII")
      cond_lc_file =
        File.open(File.join(@cdatadir, "cond_lc_map"), "w:US-ASCII")
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
          end
        }
      ensure
        uc_file.close
        lc_file.close
        cond_uc_file.close
        cond_lc_file.close
      end
      sort_file(File.join(@cdatadir, "cond_uc_map"))
      sort_file(File.join(@cdatadir, "cond_lc_map"))
    end

    def compile_derived_core_properties
      lc_file =
        File.open(File.join(@cdatadir, "prop_set_lowercase"), "w:US-ASCII")
      begin
        each_derived_core_property { |dcp|
          case dcp.property
          when "Lowercase"
            lc_file.write(format_codepoint(dcp.codepoint))
          end
        }
      ensure
        lc_file.close
      end
    end

    def run
      compile_unicode_data
      compile_special_casing
      compile_derived_core_properties
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
