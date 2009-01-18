# -*- encoding: utf-8 -*-

require "unicode_utils/version"
require "unicode_utils/char_name"
require "unicode_utils/simple_upcase"
require "unicode_utils/simple_downcase"
require "unicode_utils/upcase"
require "unicode_utils/downcase"
require "unicode_utils/titlecase_char_q"
require "unicode_utils/lowercase_char_q"
require "unicode_utils/uppercase_char_q"
require "unicode_utils/cased_char_q"
require "unicode_utils/case_ignorable_char_q"
require "unicode_utils/soft_dotted_char_q"
require "unicode_utils/combining_class"
require "unicode_utils/hangul_syllable_decomposition"
require "unicode_utils/jamo_short_name"
require "unicode_utils/canonical_decomposition"
require "unicode_utils/nfd"
require "unicode_utils/canonical_equivalents_q"
require "unicode_utils/nfc"
require "unicode_utils/compatibility_decomposition"
require "unicode_utils/nfkd"
require "unicode_utils/nfkc"
require "unicode_utils/codepoint"
require "unicode_utils/grep"
require "unicode_utils/simple_casefold"
require "unicode_utils/casefold"
require "unicode_utils/each_grapheme"
require "unicode_utils/each_word"

# Read the README[link:files/README_txt.html] for an introduction.
#
# Highlevel functions are:
#
# UnicodeUtils.upcase:: full conversion to uppercase
# UnicodeUtils.downcase:: full conversion to lowercase
# UnicodeUtils.nfd:: Normalization Form D
# UnicodeUtils.nfc:: Normalization Form C
# UnicodeUtils.nfkd:: Normalization Form KD
# UnicodeUtils.nfkc:: Normalization Form KC
# UnicodeUtils.char_name:: character names
# UnicodeUtils.casefold:: case folding (case insensitive string comparison)
module UnicodeUtils
end
