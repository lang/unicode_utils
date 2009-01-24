# -*- encoding: utf-8 -*-

require "benchmark"

require "unicode_utils/titlecase"

TXT_DIR = File.join(File.dirname(__FILE__), "..", "test")

def read_txt(filename)
  File.read(File.join(TXT_DIR, filename), mode: "r:UTF-8:-")
end

german_text = read_txt("dreilaendereck.txt")
long_german_text = german_text * 30

Benchmark.bm(35) do |x|
  x.report "titlecase" do
    30.times { UnicodeUtils.titlecase(german_text) }
  end
  x.report "titlecase, long text" do
    1.times { UnicodeUtils.titlecase(long_german_text) }
  end
end
