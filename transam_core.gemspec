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

  s.metadata = { "load_order" => "1" }

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]


  s.add_dependency 'rails', '~> 4.1.8'
  s.add_dependency "cancan"
  s.add_dependency "devise", '~> 3.2.2'
  s.add_dependency "rolify", '~> 4.1'
  s.add_dependency "high_voltage"
  #s.add_dependency "fullcalendar-rails"
  #s.add_dependency 'mail', '2.5.4'
  s.add_dependency 'unitwise'
  s.add_dependency 'chronic'
  s.add_dependency "breadcrumbs_on_rails"
  s.add_dependency 'state_machine'
  s.add_dependency 'fog'
  s.add_dependency 'carrierwave'
  s.add_dependency 'kaminari'
  s.add_dependency 'countries'
  # for background processing jobs
  s.add_dependency 'delayed_job_active_record'
  s.add_dependency 'haml-rails'
  s.add_dependency 'rmagick'

  s.add_dependency 'simple_form'

  s.add_development_dependency 'mail', '2.5.4'
  #s.add_development_dependency "rspec-rails"
  #s.add_development_dependency "factory_girl_rails"
  #s.add_development_dependency "database_cleaner"
  s.add_development_dependency "mysql2"
  #s.add_development_dependency "cucumber-rails"

end
