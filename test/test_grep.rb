# encoding: utf-8

require "test/unit"

require "unicode_utils/grep"

class TestGrep < Test::Unit::TestCase

  def test_angstrom
    assert_equal [0x212b], UnicodeUtils.grep(/angstrom/).map(&:ord)
  end

end
