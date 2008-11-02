# encoding: utf-8

require "unicode_utils/read_codepoint_set"

module UnicodeUtils

  TITLECASE_LETTER_SET = Impl.read_codepoint_set("cat_set_titlecase")

  # True if the given character has the General_Category
  # Titlecase_Letter (Lt).
  def titlecase?(char)
    TITLECASE_LETTER_SET[char.ord] || false
  end
  module_function :titlecase?

end
