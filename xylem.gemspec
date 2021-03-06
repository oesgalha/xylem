# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xylem/version'

Gem::Specification.new do |spec|
  spec.name          = 'xylem'
  spec.version       = Xylem::VERSION
  spec.authors       = ['Oscar Esgalha']
  spec.email         = ['oscaresgalha@gmail.com']
  spec.summary       = %q{Xylem uses the Adjacency List approach to store and query through hierarchical data with ActiveRecord.}
  spec.description   = %q{Xylem provides a simple way to store and retrieve hierarchical data through ActiveRecord.}
  spec.homepage      = 'https://github.com/oesgalha/xylem'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '>= 4.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.6'
  spec.add_development_dependency 'pg', '>= 0.11'
  spec.add_development_dependency 'sqlite3'
end
