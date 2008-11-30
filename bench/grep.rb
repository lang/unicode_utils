# -*- encoding: utf-8 -*-

require "benchmark"

require "unicode_utils/grep"

Benchmark.bm { |x|
  x.report("angstrom") {
    UnicodeUtils.grep(/angstrom/)
  }
}
