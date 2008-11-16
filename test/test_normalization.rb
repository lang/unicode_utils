# -*- encoding: utf-8 -*-

require "test/unit"

require "unicode_utils/nfd"
require "unicode_utils/nfc"

# See data/NormalizationTest.txt
class TestNormalization < Test::Unit::TestCase

  class Record
    def initialize(ary)
      @ary = ary
    end
    def c1
      @ary[0]
    end
    def c2
      @ary[1]
    end
    def c3
      @ary[2]
    end
    def c4
      @ary[3]
    end
    def c5
      @ary[4]
    end
  end

  def each_testdata_record
    fn = File.join(File.dirname(__FILE__),
                   "..", "data", "NormalizationTest.txt")
    File.open(fn, "r:utf-8:-") do |input|
      input.each_line { |line|
        if line =~ /^([^#]*)#/
          line = $1
        end
        line.strip!
        next if line.empty? || line =~ /^@Part/
        columns = line.split(";")
        ary = columns.map { |column|
          String.new.force_encoding(Encoding::UTF_8).tap do |str|
            column.split(" ").each { |c|
              str << c.strip.to_i(16)
            }
          end
        }
        yield Record.new(ary)
      }
    end
  end

  def test_nfd
    each_testdata_record { |r|
      assert_equal r.c3, UnicodeUtils.nfd(r.c1)
      assert_equal r.c3, UnicodeUtils.nfd(r.c2)
      assert_equal r.c3, UnicodeUtils.nfd(r.c3)
      assert_equal r.c5, UnicodeUtils.nfd(r.c4)
      assert_equal r.c5, UnicodeUtils.nfd(r.c5)
    }
  end

  def test_nfc
    each_testdata_record { |r|
      assert_equal r.c2, UnicodeUtils.nfc(r.c1)
      assert_equal r.c2, UnicodeUtils.nfc(r.c2)
      assert_equal r.c2, UnicodeUtils.nfc(r.c3)
      assert_equal r.c4, UnicodeUtils.nfc(r.c4)
      assert_equal r.c4, UnicodeUtils.nfc(r.c5)
    }
  end

end
