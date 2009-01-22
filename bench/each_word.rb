# -*- encoding: utf-8 -*-

require "benchmark"

require "unicode_utils/each_word"

TXT_DIR = File.join(File.dirname(__FILE__), "..", "test")

def read_txt(filename)
  File.read(File.join(TXT_DIR, filename), mode: "r:UTF-8:-")
end

german_text = read_txt("dreilaendereck.txt")
long_german_text = german_text * 30

Benchmark.bm(35) do |x|
  x.report "each_word" do
    30.times { UnicodeUtils.each_word(german_text) { |w| w } }
  end
  x.report "each_word, long text" do
    1.times { UnicodeUtils.each_word(long_german_text) { |w| w } }
  end
end
