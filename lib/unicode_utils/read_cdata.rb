# -*- encoding: utf-8 -*-

module UnicodeUtils

  # Absolute path to the directory from which UnicodeUtils loads its
  # compiled Unicode data files at runtime.
  CDATA_DIR = File.absolute_path(File.join(File.dirname(__FILE__), "..", "..", "cdata"))

  module Impl # :nodoc:

    def self.open_cdata_file(filename, &block)
      File.open(File.join(CDATA_DIR, filename), "r:US-ASCII:-", &block)
    end

    def self.read_codepoint_set(filename)
      Hash.new.tap { |set|
        open_cdata_file(filename) do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            set[buffer.to_i(16)] = true
          end
        end
      }
    end

    def self.read_codepoint_map(filename)
      Hash.new.tap { |map|
        open_cdata_file(filename) do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            map[buffer.to_i(16)] = input.read(6, buffer).to_i(16)
          end
        end
      }
    end

    def self.read_multivalued_map(filename)
      Hash.new.tap { |map|
        open_cdata_file(filename) do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            cp = buffer.to_i(16)
            mapping = []
            while input.read(6, buffer).getbyte(0) != 120
              mapping << buffer.to_i(16)
            end
            map[cp] = mapping
          end
        end
      }
    end

    def self.read_names(filename)
      Hash.new.tap { |map|
        open_cdata_file(filename) do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            map[buffer.to_i(16)] = input.gets.tap { |x| x.chomp! }
          end
        end
      }
    end

    def self.read_conditional_casings(filename)
      Hash.new.tap { |cp_map|
        open_cdata_file(filename) do |input|
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

    def self.read_combining_class_map
      Hash.new.tap { |map|
        open_cdata_file("combining_class_map") do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          cc_buffer = "x" * 2
          cc_buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            map[buffer.to_i(16)] = input.read(2, cc_buffer).to_i(16)
          end
        end
      }
    end

    # Read a map whose keys are codepoints (6 hexgdigits, converted to
    # integer) and whose values are single hexdigits (converted to
    # integer).
    def self.read_hexdigit_map(filename)
      Hash.new.tap { |map|
        open_cdata_file(filename) do |input|
          buffer = "x" * 6
          buffer.force_encoding(Encoding::US_ASCII)
          val_buffer = "x"
          val_buffer.force_encoding(Encoding::US_ASCII)
          while input.read(6, buffer)
            map[buffer.to_i(16)] = input.read(1, val_buffer).to_i(16)
          end
        end
      }
    end

  end

end
