
require "#{File.dirname(__FILE__)}/lib/unicode_utils/version"

gem_filename = "unicode_utils-#{UnicodeUtils::VERSION}.gem"

desc "Build unicode_utils gem."
task "gem" do
  sh "gem19 build unicode_utils.gemspec"
  mkdir "pkg" unless File.directory? "pkg"
  mv gem_filename, "pkg"
end

desc "Run rdoc to generate html documentation."
task "doc" do
  sh "rdoc19 -o doc lib"
end

desc "Remove generated packages and documentation."
task "clean" do
  rm_r "pkg" if File.exist? "pkg"
  rm_r "doc" if File.exist? "doc"
end
