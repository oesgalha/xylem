require 'bundler/gem_tasks'

task :test do
  $LOAD_PATH.unshift('lib', 'test')
  require './test/xylem_tests.rb'
end

task :bench do
  ['acts_as_tree', 'ancestry', 'awesome_nested_set', 'xylem'].each do |benched_gem|
    sh "cd bench/ && BENCH_GEM=#{benched_gem} ruby benchmark.rb"
  end
end

task default: :test
