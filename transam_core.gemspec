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

  s.add_dependency 'active_record-acts_as'

  s.add_dependency 'rails', '~> 5.2.0'
  s.add_dependency 'uglifier' # Use Uglifier as compressor for JavaScript assets
  s.add_dependency "cancancan"
  s.add_dependency "devise"
  s.add_dependency "rolify"
  s.add_dependency 'rails_email_validator'
  s.add_dependency "high_voltage"
  #s.add_dependency "fullcalendar-rails"
  s.add_dependency 'bootstrap-datepicker-rails'
  #s.add_dependency 'mail', '2.5.4'
  s.add_dependency 'unitwise'
  s.add_dependency 'chronic'
  s.add_dependency "breadcrumbs_on_rails"
  s.add_dependency "gritter"

  s.add_dependency 'paper_trail', '~> 11.1'
  s.add_dependency 'paper_trail-association_tracking'
  s.add_dependency 'paper_trail-globalid'

  s.add_dependency 'state_machines'
  s.add_dependency 'state_machines-activemodel'
  s.add_dependency 'state_machines-activerecord'

  s.add_dependency 'roo-xls'
  s.add_dependency  'rubyXL', '3.1.0'
  s.add_dependency 'carrierwave', '~> 2.2.5'
  s.add_dependency 'carrierwave-aws'
  s.add_dependency 'mimemagic', '~> 0.3.0' # Rails no longer depends on mimemagic but carrierwave still does
  s.add_dependency 'countries'
  # for background processing jobs
  s.add_dependency 'delayed_job_active_record'

  #pagination
  s.add_dependency 'kaminari'
  s.add_dependency 'api-pagination'

  s.add_dependency 'bootstrap-sass'
  s.add_dependency 'haml-rails'
  s.add_dependency 'rmagick'

  s.add_dependency 'simple_form'
  s.add_dependency 'country_select'
  s.add_dependency 'font-awesome-sass'
  s.add_dependency "wicked"
  s.add_dependency 'cocoon'
  s.add_dependency 'bootstrap-editable-rails'

  # Use jquery as the JavaScript library
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'jquery-form-rails'

  s.add_dependency 'rails-data-migrations'

  # API
  #s.add_dependency 'zero-rails_openapi'
  s.add_dependency 'jbuilder'
  s.add_dependency 'simple_token_authentication', '~> 1.0'

  s.add_dependency 'deep_cloneable'

  s.add_dependency 'browser'

  s.add_dependency 'selectize-rails'

  s.add_dependency 'aws-sdk-s3'
  s.add_dependency 'aws-sdk-cloudwatch'

  # Deal with security issues
  s.add_dependency 'nokogiri', '>= 1.13.4'
  
  # Development
  s.add_development_dependency 'mail', '2.5.5'
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "faker"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "cucumber-rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "codacy-coverage"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "rb-readline"
end
