# -*- encoding: utf-8 -*-

require "rbconfig"
require "fileutils"

sitelibdir = Config::CONFIG['sitelibdir']
installdir = ARGV[1] || sitelibdir

HELP = <<EOF
Install unicode_utils.

installdir defaults to Ruby's sitelibdir, which you can get
with:
  
  $ ruby -r rbconfig -e "puts Config::CONFIG['sitelibdir']"

sitelibdir is #{sitelibdir.inspect}
installdir is #{installdir.inspect}

Possible commands are:

ruby install.rb install [installdir]
  Install unicode_utils in installdir. Fails when an
  existing installation is found. Doesn't overwrite
  existing files.

ruby install.rb check [installdir]
  Check if unicode_utils is installed in installdir.

ruby install.rb uninstall [installdir]
  Remove an existing unicode_utils installation in installdir.

ruby install.rb help
  Show this help.
EOF

def check(installdir)
  puts "Checking for unicode_utils installation in #{installdir.inspect}"
  found = false
  if File.exist?(File.join(installdir, "unicode_utils.rb"))
    puts "Found unicode_utils.rb"
    found = true
  end
  if File.exist?(File.join(installdir, "unicode_utils"))
    puts "Found unicode_utils/"
    found = true
  end
  unless found
    puts "No unicode_utils files/directories found."
  end
  found
end

def uninstall(installdir)
  return unless check(installdir)
  if File.exist?(File.join(installdir, "unicode_utils.rb"))
    FileUtils::Verbose.rm File.join(installdir, "unicode_utils.rb")
  end
  if File.exist?(File.join(installdir, "unicode_utils"))
    FileUtils::Verbose.rm_r File.join(installdir, "unicode_utils")
  end
end

def install(installdir)
  if check(installdir)
    puts "You must run uninstall before install."
    exit 1
  end
  installdir_lib = File.join(installdir, "unicode_utils")
  FileUtils::Verbose.install "lib/unicode_utils.rb", installdir, mode: 0755
  FileUtils::Verbose.mkdir installdir_lib
  FileUtils::Verbose.install Dir["cdata/*"], installdir_lib, mode: 0755
  found_cdata_dir = false
  Dir.entries("lib/unicode_utils").each { |fn|
    next unless fn =~ /.\.rb$/
    if fn == "read_cdata.rb"
      puts "writing read_cdata.rb"
      File.open(File.join("lib/unicode_utils/read_cdata.rb"), "r:utf-8") do |input|
        File.open(File.join(installdir_lib, "read_cdata.rb"), "w:utf-8") do |output|
          input.each_line { |line|
            if line =~ /^(\s+)CDATA_DIR =/
              found_cdata_dir = true
              puts "Setting CDATA_DIR to File.absolute_path(File.dirname(__FILE__))"
              output.puts "#$1CDATA_DIR = File.absolute_path(File.dirname(__FILE__))"
            else
              output.puts line
            end
          }
        end
      end
      FileUtils::Verbose.chmod 0755, File.join(installdir_lib, "read_cdata.rb")
    else
      FileUtils::Verbose.install File.join("lib/unicode_utils", fn), installdir_lib, mode: 0755
    end
  }
  unless found_cdata_dir
    puts "CDATA_DIR definition not found."
    puts "Installation aborted."
    exit 1
  end
  puts "Successfully installed unicode_utils in #{installdir.inspect}."
end

case ARGV[0]
when "help"
  print HELP
when "install"
  install(installdir)
when "check"
  check(installdir)
when "uninstall"
  uninstall(installdir)
else
  print HELP
  exit 1
end
