#encoding: utf-8


# Load seeds used by initializers

# Only run any of this code if we're in the test environment
if Rails.env.test?

  # Determine if we are using postgres or mysql
  is_mysql = (ActiveRecord::Base.configurations[Rails.env]['adapter'].include? 'mysql2')

  # ====================================================================

  # Create the database if it does not exist

  # If it does exist this will do no harm
  # Uses a DatabaseTask method instead of Rake::Task["db:create"].invoke
  # This prevents interference with other Rake tasks

  # ====================================================================

  ActiveRecord::Tasks::DatabaseTasks.create_current(Rails.env)

  # =============================================================================

  # Find out if the seed tables already exist

  # If not, they will likely be created by db:schema:load or db:migrate
  # So we'll want to drop the ones made here after initialization, to make room
  # This is handled at the end of this file

  # Not needed since both db:schema:load and db:migrate always use :force => true
  # But including for future reference

  # =============================================================================

  system_configs_exists_before_init = ActiveRecord::Base.connection.table_exists?(:system_configs)

  # =====================================================================

  # Create the seed tables

  # Mirror the existing state of each table in the schema
  # And mirror each instance of it created in the seeds file

  # But adjust if you are introducing a migration that will change either

  # =====================================================================

  ActiveRecord::Base.connection.create_table "system_configs", :force => true do |t|
    t.integer  "customer_id"
    t.string   "start_of_fiscal_year",  :limit => 5
    t.string   "map_tile_provider",     :limit => 64
    t.integer  "srid"
    t.float    "min_lat",               :limit => 24
    t.float    "min_lon",               :limit => 24
    t.float    "max_lat",               :limit => 24
    t.float    "max_lon",               :limit => 24
    t.integer  "search_radius"
    t.string   "search_units",          :limit => 8
    t.string   "geocoder_components",   :limit => 128
    t.string   "geocoder_region",       :limit => 64
    t.integer  "num_forecasting_years"
    t.integer  "num_reporting_years"
    t.string   "asset_base_class_name", :limit => 64
    t.integer  "max_rows_returned"
    t.string   "data_file_path",        :limit => 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  puts "======= Loading Tables Used By Initializers ======="

  system_configs = [
    { :customer_id => 1,
      :start_of_fiscal_year => '07-01',
      :map_tile_provider => 'GOOGLEMAP',
      :srid => 3857,
      :min_lat => 39.721712,
      :min_lon => -80.518166,
      :max_lat => 42.049293,
      :max_lon => -74.70746,
      :search_radius => 300,
      :search_units => 'ft',
      :geocoder_components => 'administrative_area:PA|country:US',
      :geocoder_region => 'us',
      :num_forecasting_years => 12,
      :num_reporting_years => 20,
      :asset_base_class_name => 'Asset',
      :max_rows_returned => 500,
      :data_file_path => '/data/'
    }
  ]

  replace_tables = %w{ system_configs }

  replace_tables.each do |table_name|
    puts "  Loading #{table_name}"
    if is_mysql
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
    else
      ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
    end
    data = eval(table_name)
    klass = table_name.classify.constantize
    data.each do |row|
      x = klass.new(row)
      x.save!
    end
  end

  # ====================================================================

  # Drop the tables after initialization if they did not exist before it

  # ====================================================================

  Dummy::Application.configure do
    config.after_initialize do
      unless system_configs_exists_before_init
        puts "  Dropping system_configs to make room for its recreation"
        ActiveRecord::Base.connection.drop_table :system_configs
      end
    end
  end

end
