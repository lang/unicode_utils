# -*- encoding: utf-8 -*-

require "benchmark"

require "unicode_utils/nfd"
require "unicode_utils/nfkd"
require "unicode_utils/nfc"
require "unicode_utils/nfkc"

TXT_DIR = File.join(File.dirname(__FILE__), "..", "test")

def read_txt(filename)
  File.read(File.join(TXT_DIR, filename), mode: "r:UTF-8:-")
end

german_text = read_txt("dreilaendereck.txt")
long_german_text = german_text * 100

Benchmark.bmbm do |x|
  x.report "nfd" do
    100.times { UnicodeUtils.nfd(german_text) }
  end
  x.report "nfd, long text" do
    1.times { UnicodeUtils.nfd(long_german_text) }
  end
  x.report "nfkd" do
    100.times { UnicodeUtils.nfkd(german_text) }
  end
  x.report "nfkd, long text" do
    1.times { UnicodeUtils.nfkd(long_german_text) }
  end
  x.report "nfc" do
    100.times { UnicodeUtils.nfc(german_text) }
  end
  x.report "nfc, long text" do
    1.times { UnicodeUtils.nfc(long_german_text) }
  end
  x.report "nfkc" do
    100.times { UnicodeUtils.nfkc(german_text) }
  end
  x.report "nfkc, long text" do
    1.times { UnicodeUtils.nfkc(long_german_text) }
  end
end
