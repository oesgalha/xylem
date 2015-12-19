require 'bundler/gem_tasks'

task :test do
  $LOAD_PATH.unshift('lib', 'test')
  require './test/xylem_tests.rb'
end

task default: :test
