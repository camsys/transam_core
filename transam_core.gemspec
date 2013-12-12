# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'transam_core/version'

Gem::Specification.new do |spec|
  spec.name          = "transam_core"
  spec.version       = TransamCore::VERSION
  spec.authors       = ["Julian Ray"]
  spec.email         = ["jray@camsys.com"]
  spec.description   = %q{Base TransAM platform}
  spec.summary       = %q{Base TransAM platform}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "devise"
  spec.add_development_dependency "paper_trail"
  spec.add_development_dependency "rolify"
  spec.add_development_dependency "georuby"
  spec.add_development_dependency "ruby-units"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
