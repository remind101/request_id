# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'request_id/version'

Gem::Specification.new do |spec|
  spec.name          = 'request_id'
  spec.version       = RequestId::VERSION
  spec.authors       = ['Eric J. Holmes']
  spec.email         = ['eric@ejholmes.net']
  spec.description   = %q{Classes for tracking request id}
  spec.summary       = %q{Classes for tracking request id}
  spec.homepage      = 'https://github.com/remind101/request_id'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
