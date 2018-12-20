# encoding: utf-8

require "#{File.dirname(__FILE__)}/lib/unicode_utils/version"

files =
  Dir["lib/**/*.rb"] + Dir["cdata/*"] +
  ["README.rdoc", "INSTALL.txt", "LICENSE.txt", "CHANGES.txt"]
files.reject! { |fn| fn.end_with?("~") }

Gem::Specification.new do |g|
  g.name = "unicode_utils"
  g.version = UnicodeUtils::VERSION
  g.platform = Gem::Platform::RUBY
  g.summary = "Additional Unicode aware functions for Ruby 1.9+."
  g.require_paths = ["lib"]
  g.files = files
  g.required_ruby_version = ">= 1.9.1"
  g.author = "Stefan Lang"
  g.email = "langstefan@gmx.at"
  g.extra_rdoc_files = ["README.rdoc", "INSTALL.txt", "CHANGES.txt"]
  g.rdoc_options = ["--main=README.rdoc", "--charset=UTF-8"]
  g.homepage = "https://github.com/lang/unicode_utils"
  g.rubyforge_project = "unicode-utils"
end
