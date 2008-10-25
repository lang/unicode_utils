# encoding: UTF-8

module UnicodeFunctions

  Codepoint = Struct.new(:codepoint,
                         :name,
                         :simple_lowercase_mapping,
                         :simple_uppercase_mapping)

  CODEPOINT_TABLE = {}

  def self.read_unicode_data(io)
    io.each_line { |line|
      fields = line.split(";")
      cp = Codepoint.new
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
      CODEPOINT_TABLE[cp.codepoint] = cp
    }
  end

  data_fn = "#{File.dirname(__FILE__)}/../data/UnicodeData.txt"
  File.open(data_fn, "r:US-ASCII:UTF-8") do |io|
    read_unicode_data(io)
  end

  # Get the Unicode name of the single codepoint in str.
  def name(str)
    CODEPOINT_TABLE[str.codepoints.first].name.encode
  end
  module_function :name

  # Map each codepoint in +str+ that has a single codepoint
  # uppercase-mapping to that uppercase mapping. +str+ is assumed to be
  # in a unicode encoding. The original string is not modified. The
  # returned string has the same encoding and same length as the
  # original string.
  #
  # This function is locale independent.
  #
  # Examples:
  #
  #     UnicodeFunctions.simple_upcase("ümit: 123") => "ÜMIT: 123"
  #     UnicodeFunctions.simple_upcase("weiß") => "WEIß"
  def simple_upcase(str)
    res = String.new.force_encoding(str.encoding)
    str.each_codepoint { |cp|
      res << (CODEPOINT_TABLE[cp].simple_uppercase_mapping || cp)
    }
    res
  end
  module_function :simple_upcase

  # Map each codepoint in +str+ that has a single codepoint
  # lowercase-mapping to that lowercase mapping. +str+ is assumed to be
  # in a unicode encoding. The original string is not modified. The
  # returned string has the same encoding and same length as the
  # original string.
  #
  # This function is locale independent.
  #
  # Examples:
  #
  #     UnicodeFunctions.simple_downcase("ÜMIT: 123") => "ümit: 123"
  #     UnicodeFunctions.simple_downcase("STRASSE") => "strasse"
  def simple_downcase(str)
    res = String.new.force_encoding(str.encoding)
    str.each_codepoint { |cp|
      res << (CODEPOINT_TABLE[cp].simple_lowercase_mapping || cp)
    }
    res
  end
  module_function :simple_downcase

end
