# -*- encoding: utf-8 -*-

require "unicode_utils/read_cdata"

module UnicodeUtils

  WHITE_SPACE_SET = Impl.read_code_point_set("white_space_set") # :nodoc:

  # True if the given character has the Unicode property White_Space.
  def white_space?(char)
    WHITE_SPACE_SET.include?(char.ord)
  end
  module_function :white_space?

end
