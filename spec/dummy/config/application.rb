require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "transam_core"
require TransamCore::Engine.root.join('app/controllers/concerns/json_response_helper.rb').to_s

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.help_directory = (ENV['HELP_PATH'] || "https://camsys.github.io/transam_user_guide/user_guide")
    config.time_zone = 'Eastern Time (US & Canada)'

    # Sends back appropriate JSON 400 response if a bad JSON request is sent.
    config.middleware.insert_before Rack::Head, JsonResponseHelper::CatchJsonParseErrors
  end
end

