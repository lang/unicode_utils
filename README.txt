= Unicode Utils - Unicode algorithms for Ruby 1.9

Install with RubyGems:

    gem install unicode_utils

Or get the source from Github: http://github.com/lang/unicode_utils

UnicodeUtils works with Ruby 1.9.1-preview1 or later. Though a bug
(http://redmine.ruby-lang.org/issues/show/692) in
1.9.1-preview1 prevents UnicodeUtils from loading when
Encoding.default_internal is set (e.g. with -U or -E).

== Synopsis

    require "unicode_utils"

    UnicodeUtils.char_name("æ") => "LATIN SMALL LETTER AE"
    
    UnicodeUtils.upcase("weiß") => "WEISS"

    UnicodeUtils.upcase("i", :tr) => "İ"

    UnicodeUtils.downcase("Ümit") => "ümit"

    UnicodeUtils.nfkc("ﬁ") => "fi"

Start with the UnicodeUtils module in the API documentation for
complete documentation.

Since some functions need significant amounts of data that is loaded
at require time, the library is split up into separate files for
each function. The +unicode_utils+ library loads them all. If you
need only a specific function, e.g. +upcase+, you can require only
the file <tt>unicode_utils/upcase</tt> to save memory and reduce
startup time. Methods that end in a ? are in a file suffixed with
+_q+, e.g. <tt>lowercase_char?</tt> can be required with
<tt>unicode_utils/lowercase_char_q</tt>.

== License

unicode_utils is licensed under the BSD license. Read the file
LICENSE.txt in the unicode_utils package for details.

== Links

Sources on Github:: http://github.com/lang/unicode_utils
Rubyforge project:: http://rubyforge.org/projects/unicode-utils
Online documentation:: http://unicode-utils.rubyforge.org
Home of the Unicode Consortium:: http://unicode.org

== Who?

UnicodeUtils is written by Stefan Lang. You can contact me at
<tt>langstefan AT gmx.at</tt>. Contributions welcome!
