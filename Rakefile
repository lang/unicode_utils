# encoding: utf-8

require "#{File.dirname(__FILE__)}/lib/unicode_utils/version"

suffix = ENV["SUFFIX"]

gem_filename = "unicode_utils-#{UnicodeUtils::VERSION}.gem"

task "default" => "quick-test"

desc "Run unit tests."
task "test" do
  ruby "-I lib test/suite.rb"
end

desc "Quick test run."
task "quick-test" do
  ruby "-I lib -I . test/test_unicode_utils.rb"
end

desc "Run tests and generate coverage report."
task "coverage" do
  ruby "-I lib test/coverage.rb"
end

desc "Build unicode_utils gem."
task "gem" do
  sh "gem#{suffix} build unicode_utils.gemspec"
  mkdir "pkg" unless File.directory? "pkg"
  mv gem_filename, "pkg"
end

desc "Update data/"
task "update" do
  cd 'data' do
    sh 'wget -np -I /Public/UCD/latest/ucd/ -X /Public/UCD/latest/ucd/auxiliary/ -X /Public/UCD/latest/ucd/extracted -R "index.html*" -R "*.zip" -R "*.pdf" -mk http://www.unicode.org/Public/UCD/latest/ucd/'
    sh 'mv www.unicode.org/Public/UCD/latest/ucd/* .'
    sh 'rm -rf  www.unicode.org'
  end
end

desc "Run rdoc to generate html documentation."
task "doc" do
  sh "rdoc#{suffix} -o doc --charset=UTF-8 --title=UnicodeUtils --main=README.rdoc lib README.rdoc INSTALL.txt CHANGES.txt LICENSE.txt"
end

desc "Publish doc/ on unicode-utils.rubyfore.org. " +
     "Note: scp will prompt for rubyforge password."
task "publish-doc" => "doc" do
    sh "scp -i ~/.ssh/id_rsa_s0 -r doc/* langi@rubyforge.org:/var/www/gforge-projects/unicode-utils/"
end

desc "Compile Unicode data files from data/ to cdata/."
task "compile-data" do
  ruby "data/compile.rb"
end

desc "Remove generated packages and documentation."
task "clean" do
  rm_r "pkg" if File.exist? "pkg"
  rm_r "doc" if File.exist? "doc"
end
