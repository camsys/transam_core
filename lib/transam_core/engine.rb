require 'active_record/acts_as'
require 'devise'
require 'rolify'
require 'cancan'
require 'unitwise'
require 'chronic'
require 'breadcrumbs_on_rails'
require 'state_machines'
require 'state_machines-activemodel'
require 'state_machines-activerecord'
require 'delayed_job'
require 'delayed_job_active_record'
require 'high_voltage'
require 'haml-rails'
require 'simple_form'
require 'country_select'
require 'gritter'
require 'fog'
require 'carrierwave'
require 'rmagick'
require 'countries'
require 'rails-data-migrations'
require 'font-awesome-sass'
require 'bootstrap-datepicker-rails'
require 'bootstrap-editable-rails'
require 'bootstrap-sass'
require 'wicked'
require 'cocoon'
require 'jquery-ui-rails'
require 'jquery-form-rails'
require 'selectize-rails'
require 'roo-xls'
require 'kaminari'

require 'paper_trail'
require 'paper_trail-association_tracking'
require 'paper_trail-globalid'

require 'deep_cloneable'

# API
#require 'open_api'
require 'jbuilder'
require 'responders'
require 'simple_token_authentication'
require 'api-pagination'

module TransamCore
  class Engine < ::Rails::Engine
    # Add a load path for this specific Engine
    config.autoload_paths += %W(#{Rails.root}/app/calculators)
    config.autoload_paths += %W(#{Rails.root}/app/file_handlers)
    config.autoload_paths += %W(#{Rails.root}/app/jobs)
    config.autoload_paths += %W(#{Rails.root}/app/reports)
    config.autoload_paths += %W(#{Rails.root}/app/searches)
    config.autoload_paths += %W(#{Rails.root}/app/services)
    config.autoload_paths += %W(#{Rails.root}/app/uploaders)

    # Append migrations from the engine into the main app
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
        app.config.paths.add "db/data_migrations"
        config.paths.add "db/data_migrations"
        config.paths["db/data_migrations"].expanded.each do |expanded_path|
          app.config.paths["db/data_migrations"] << expanded_path
        end
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
