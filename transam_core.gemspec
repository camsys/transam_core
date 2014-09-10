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


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
  s.add_dependency 'rails', '~> 4.0.2'
  s.add_dependency "cancan"
  s.add_dependency "devise", '~> 3.2.2'
  s.add_dependency "rolify", '~> 3.4'
  s.add_dependency "georuby"
  s.add_dependency "high_voltage"
  s.add_dependency "fullcalendar-rails"
  
  # for background processing jobs  
  s.add_dependency 'delayed_job_active_record'
  # for running background processes
  s.add_dependency 'daemons'
  
  s.add_development_dependency "rolify", '~> 3.4'
  s.add_development_dependency "devise", '~> 3.2.2'
  s.add_development_dependency 'devise_security_extension'
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "sqlite3"  

end
