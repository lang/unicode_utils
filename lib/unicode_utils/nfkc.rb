# -*- encoding: utf-8 -*-

require "unicode_utils/compatibility_decomposition"
require "unicode_utils/nfc"

module UnicodeUtils

  # Get +str+ in Normalization Form KC.
  def nfkc(str)
    str = UnicodeUtils.compatibility_decomposition(str)
    Impl.composition(str)
  end
  module_function :nfkc

end
