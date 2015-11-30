# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'good'

Gem::Specification.new do |spec|
  spec.name          = "good"
  spec.version       = Good::VERSION
  spec.authors       = ["Rafer Hazen"]
  spec.email         = ["rafer@ralua.com"]
  spec.summary       = %q{Good::Value and Good::Record}
  spec.homepage      = "https://github.com/rafer/good"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 2.0 "
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
