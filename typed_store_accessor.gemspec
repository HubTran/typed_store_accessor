# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'typed_store_accessor/version'

Gem::Specification.new do |spec|
  spec.name          = "typed_store_accessor"
  spec.version       = TypedStoreAccessor::VERSION
  spec.authors       = ["Randy Schmidt"]
  spec.email         = ["me@r38y.com"]

  spec.summary       = %q{Helper for specifying typed accessors for hash-like columns in a table}
  spec.description   = %q{See summary.}
  spec.homepage      = "https://github.com/HubTran/typed_store_accessor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug"
  spec.add_dependency "activesupport", ">= 5"
  spec.add_dependency "activerecord", ">= 5"
end
