$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "transam_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "transam_core"
  s.version     = TransamCore::VERSION
  s.authors     = ["Julian Ray"]
  s.email       = ["jray@camsys.com"]
  s.homepage    = "http://www.camsys.com"
  s.summary     = "TransAM Asset Management Platform."
  s.description = "TransAM Asset Management Platform."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "devise"
  s.add_dependency "rolify"
  s.add_dependency "georuby"
  s.add_dependency "paper_trail"
  s.add_dependency "high_voltage"
  
  # for background processing jobs  
  s.add_dependency 'delayed_job_active_record'
  # for running background processes
  s.add_dependency 'daemons'
  
end
