# -*- encoding: utf-8 -*-

require "benchmark"

require "unicode_utils/upcase"
require "unicode_utils/downcase"

TXT_DIR = File.join(File.dirname(__FILE__), "..", "test")

def read_txt(filename)
  File.read(File.join(TXT_DIR, filename), mode: "r:UTF-8:-")
end

german_text = read_txt("dreilaendereck.txt")
long_german_text = german_text * 100

Benchmark.bm(35) do |x|
  x.report "String#upcase" do
    100.times { german_text.upcase }
  end
  x.report "upcase, no language" do
    100.times { UnicodeUtils.upcase(german_text) }
  end
  x.report "upcase, :de" do
    100.times { UnicodeUtils.upcase(german_text, :de) }
  end
  x.report "upcase, :tr" do
    100.times { UnicodeUtils.upcase(german_text, :de) }
  end
  x.report "long text: String#upcase" do
    1.times { long_german_text.upcase }
  end
  x.report "long text: upcase, no language" do
    1.times { UnicodeUtils.upcase(long_german_text) }
  end
  x.report "long text: upcase, :de" do
    1.times { UnicodeUtils.upcase(long_german_text, :de) }
  end
  x.report "long text: upcase, :tr" do
    1.times { UnicodeUtils.upcase(long_german_text, :tr) }
  end

  x.report "String#downcase" do
    100.times { german_text.downcase }
  end
  x.report "downcase, no language" do
    100.times { UnicodeUtils.downcase(german_text) }
  end
  x.report "downcase, :de" do
    100.times { UnicodeUtils.downcase(german_text, :de) }
  end
  x.report "downcase, :tr" do
    100.times { UnicodeUtils.downcase(german_text, :de) }
  end
  x.report "long text: String#downcase" do
    1.times { long_german_text.downcase }
  end
  x.report "long text: downcase, no language" do
    1.times { UnicodeUtils.downcase(long_german_text) }
  end
  x.report "long text: downcase, :de" do
    1.times { UnicodeUtils.downcase(long_german_text, :de) }
  end
  x.report "long text: downcase, :tr" do
    1.times { UnicodeUtils.downcase(long_german_text, :tr) }
  end
end
