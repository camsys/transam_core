class SystemConfig < ActiveRecord::Base
  
  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  def self.instance
    # there will be only one row, and its ID must be '1'
    find(1)
  end
      
  # Validations on core attributes
  validates :customer_id,                 :presence => true, :uniqueness => true
  validates :map_tile_provider,           :presence => true
  validates :srid,                        :presence => true
  validates :min_lat,                     :presence => true
  validates :min_lon,                     :presence => true
  validates :max_lat,                     :presence => true
  validates :max_lon,                     :presence => true
  validates :search_radius,               :presence => true
  validates :search_units,                :presence => true
  validates :geocoder_components,         :presence => true
  validates :geocoder_region,             :presence => true
  validates :num_forecasting_years,       :presence => true
  validates :num_reporting_years,         :presence => true
  validates :asset_base_class_name,       :presence => true
  validates :max_rows_returned,           :presence => true
  validates :data_file_path,              :presence => true
  validates :new_inventory_template_name, :presence => true
      
  def geocoder_bounds
    [[min_lat, min_lon], [max_lat, max_lon]]
  end    
  def map_bounds
    [[min_lat, min_lon], [max_lat, max_lon]]
  end    
end
