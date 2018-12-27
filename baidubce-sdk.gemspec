# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'baidubce/version'

Gem::Specification.new do |spec|
  spec.name          = "baidubce-sdk"
  spec.version       = Baidubce::VERSION
  spec.authors       = ["xiaoyong"]
  spec.email         = ["yxiaoak@163.com"]

  spec.summary       = 'BaiduBce BOS Ruby SDK'
  spec.description   = 'The official Ruby sdk used to accessing BaiduBce Object Storage Service'
  spec.homepage      = "https://github.com/baidubce/bce-sdk-ruby"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "lib/baidubce"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rest-client", "~> 2.0", ">= 2.0.2"
  spec.add_development_dependency "logger", "~> 1.2", ">= 1.2.8"
  spec.add_development_dependency "mimemagic", "~> 0.3", ">= 0.3.2"
  spec.required_ruby_version = ">= 2.0.0"
end
