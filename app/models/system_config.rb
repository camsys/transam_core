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
  validates :start_of_fiscal_year,        :presence => true
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
      
  def geocoder_bounds
    [[min_lat, min_lon], [max_lat, max_lon]]
  end    
  def map_bounds
    [[min_lat, min_lon], [max_lat, max_lon]]
  end    
  
  #
  # Queries the gemspec to see if the transam extension has been loaded.
  # examples:
  # if SystemConfig.transam_engine_loaded? 'transit'
  # SystemConfig.transam_engine_loaded? :cpt
  # if SystemConfig.transam_engine_loaded? ('core', '>= 0.4.0')
  #
  # By convention all transam engines are named 'transam_xxx'. The name
  # of the engine can be passsed as a string 'core' or symbol :transit
  #
  def self.transam_module_loaded? (engine_name, version = nil)
    if version.blank?
      Gem::Specification::find_all_by_name("transam_#{engine_name.to_s}").any?
    else
      Gem::Specification::find_all_by_name("transam_#{engine_name.to_s}", version).any?
    end
  end
  
  #
  # Queries the gemspec and returns an array of transam modules that have been loaded
  #
  def self.transam_modules
    a = []
    Gem::Specification::each do |gem|
      if gem.full_name.start_with? 'transam_'
        a << gem
      end
    end
    a
  end
end
