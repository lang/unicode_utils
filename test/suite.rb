Dir["#{File.dirname __FILE__}/test_*.rb"].each { |fn|
  require_relative File.basename(fn)
}
