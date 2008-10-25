# encoding: utf-8

File.open "UnicodeData.txt", "r:US-ASCII:UTF-8" do |input|
  File.open "unicode_data.rb", "w:UTF-8" do |output|
    output.puts "# encoding: utf-8"
    output.puts
    output.puts "module UnicodeUtils"
    output.puts "  CODEPOINT_TABLE = {"
    input.each_line { |line|
      fields = line.split(";")
      codepoint = fields[0].to_i(16)
      name = fields[1]
      uc_mapping = fields[12]
      if uc_mapping.empty?
        uc_mapping = nil
      else
        uc_mapping = uc_mapping.to_i(16)
      end
      lc_mapping = fields[13]
      if lc_mapping.empty?
        lc_mapping = nil
      else
        lc_mapping = lc_mapping.to_i(16)
      end
      output.puts "    #{codepoint} => [#{codepoint}, '#{name}', #{lc_mapping.inspect}, #{uc_mapping.inspect}],"
    }
    output.puts "  }"
    output.puts "end"
  end
end
