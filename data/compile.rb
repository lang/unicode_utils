# encoding: utf-8

module UnicodeUtils

  Codepoint = Struct.new(:codepoint,
                         :name,
                         :simple_lowercase_mapping,
                         :simple_uppercase_mapping)

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

    def run
      uc_file =
        File.open(File.join(@cdatadir, "simple_uc_map"), "w:US-ASCII")
      lc_file =
        File.open(File.join(@cdatadir, "simple_lc_map"), "w:US-ASCII")
      name_file =
        File.open(File.join(@cdatadir, "names"), "w:US-ASCII")
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
          name_file.write(format_codepoint(cp.codepoint))
          name_file.puts(cp.name)
        }
      ensure
        uc_file.close
        lc_file.close
        name_file.close
      end
    end

    def format_codepoint(cp)
      sprintf("%06x", cp)
    end

  end

end

if $0 == __FILE__
  UnicodeUtils::Compiler.new.run
end
