# -*- encoding: utf-8 -*-

require "benchmark"

require "unicode_utils/each_grapheme"

TXT_DIR = File.join(File.dirname(__FILE__), "..", "test")

def read_txt(filename)
  File.read(File.join(TXT_DIR, filename), mode: "r:UTF-8:-")
end

german_text = read_txt("dreilaendereck.txt")
long_german_text = german_text * 50

Benchmark.bmbm do |x|
  x.report "each_grapheme" do
    50.times { UnicodeUtils.each_grapheme(german_text) { |g| g } }
  end
  x.report "each_grapheme, long text" do
    1.times { UnicodeUtils.each_grapheme(long_german_text) { |g| g } }
  end
end
