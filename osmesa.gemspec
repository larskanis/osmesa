# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'osmesa/version'

Gem::Specification.new do |spec|
  spec.name          = "osmesa"
  spec.version       = Osmesa::VERSION
  spec.authors       = ["Lars Kanis"]
  spec.email         = ["lars@greiz-reinsdorf.de"]
  spec.summary       = %q{Mesa Off-Screen rendering interface}
  spec.description   = %q{Mesa Off-Screen rendering interface.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.extensions    = ['ext/extconf.rb']

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rake-compiler', '~> 0.9.1'
  spec.add_development_dependency 'opengl'
  spec.add_development_dependency 'minitest', '~> 5.3.0'
end
