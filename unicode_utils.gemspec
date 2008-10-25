# encoding: utf-8

require "#{File.dirname(__FILE__)}/lib/unicode_utils/version"

Gem::Specification.new do |g|
  g.name = "unicode_utils"
  g.version = UnicodeUtils::VERSION
  g.platform = Gem::Platform::RUBY
  g.summary = "additional Unicode aware functions for Ruby 1.9"
  g.require_paths = ["lib"]
  g.files = Dir["lib/**/*"].reject { |fn| fn.end_with?("~") }
  g.required_ruby_version = ">= 1.9.0"
  g.author = "Stefan Lang"
  g.email = "langstefan@gmx.at"
  g.has_rdoc = true
  g.rdoc_options = []
  g.homepage = "http://github.com/lang/unicode_utils"
  #g.rubyforge_project = "unicode_utils"
end
