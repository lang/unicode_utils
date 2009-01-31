# encoding: utf-8

require "#{File.dirname(__FILE__)}/lib/unicode_utils/version"

test_files = ["test/test_unicode_utils.rb"]
files =
  Dir["lib/**/*.rb"] + Dir["cdata/*"] + test_files +
  ["README.txt", "INSTALL.txt", "LICENSE.txt"]
files.reject! { |fn| fn.end_with?("~") }

Gem::Specification.new do |g|
  g.name = "unicode_utils"
  g.version = UnicodeUtils::VERSION
  g.platform = Gem::Platform::RUBY
  g.summary = "additional Unicode aware functions for Ruby 1.9"
  g.require_paths = ["lib"]
  g.files = files
  g.test_files = test_files
  g.required_ruby_version = ">= 1.9.1"
  g.author = "Stefan Lang"
  g.email = "langstefan@gmx.at"
  g.has_rdoc = true
  g.extra_rdoc_files = ["README.txt", "INSTALL.txt"]
  g.rdoc_options = ["--main=README.txt", "--charset=UTF-8"]
  g.homepage = "http://github.com/lang/unicode_utils"
  g.rubyforge_project = "unicode-utils"
end
