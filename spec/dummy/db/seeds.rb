TransamCore::Engine.load_seed

puts "  Processing system_config"
SystemConfig.find_or_create_by(:customer_id => 1,
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
  :max_rows_returned => 500,
  :data_file_path => '/data/'
)

puts "  processing System User"
User.find_or_create_by(
  :id => 1,
  :first_name => "system",
  :last_name => "user",
  :phone => "617-123-4567",
  :timezone => "Eastern Time (US & Canada)",
  :email => "admin@email.com",
  :num_table_rows => 10,
  )

ActiveRecord::Base.connection.execute("ALTER TABLE `transam_core_testing`.`assets` ADD COLUMN `geometry` GEOMETRY NULL AFTER `vendor_id`;")
