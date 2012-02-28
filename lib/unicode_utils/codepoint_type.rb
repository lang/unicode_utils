# -*- encoding: utf-8 -*-

require "unicode_utils/code_point_type"

module UnicodeUtils

  # Deprecated.
  #
  # Calls UnicodeUtils.code_point_type(integer). Kept only for
  # backwards compatibility.
  def codepoint_type(integer)
    UnicodeUtils.code_point_type(integer)
  end
  module_function :codepoint_type

end
