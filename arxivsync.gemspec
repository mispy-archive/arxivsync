# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arxivsync/version'

Gem::Specification.new do |spec|
  spec.name          = "arxivsync"
  spec.version       = ArxivSync::VERSION
  spec.authors       = ["Jaiden Mispy"]
  spec.email         = ["scirate@mispy.me"]
  spec.description   = %q{OAI interface for harvesting the arXiv database}
  spec.summary       = %q{OAI interface for harvesting the arXiv database}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"

  spec.add_runtime_dependency "oai"
  spec.add_runtime_dependency "colorize"
  spec.add_runtime_dependency "latex-decode"
  spec.add_runtime_dependency "ox", ">= 2.0.2" # Super-fast XML parser
  spec.add_runtime_dependency "nokogiri" # Slower but more accurate parser
end
