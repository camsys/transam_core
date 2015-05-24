#------------------------------------------------------------------------------
#
# SystemConfig
#
# This is a singleton that is used to set default options for TransAM applications
# and is used to store and access important configuration information. This
# class is immutable and cannot be updated at run time
#
# The correct way to use this class is to refer to the instance
#
#   foo = SystemConfig.instance.foo
#
#------------------------------------------------------------------------------
class SystemConfig < ActiveRecord::Base

  #------------------------------------------------------------------------------
  # Validations
  #------------------------------------------------------------------------------

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

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  def self.instance
    # there will be only one row, and its ID must be '1'
    find(1)
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
  # Queries the gemspec and returns an array of transam modules that have been loaded.
  # The array is ordered by the load order that should be specified in the gemspec.
  #
  # Load orders are sorted lowest to highest, ties broken abitarily.
  # To specifiy the load order in a module use the following in the gemspec
  #
  #   s.metadata = { "load_order" => "10" }
  #
  # which will denote a load order of 10. Core is specified as load order 1
  # as it should always be loaded first.
  #
  def self.transam_modules
    a = []
    Gem::Specification::each do |gem|
      if gem.full_name.start_with? 'transam_'
        a << [gem, gem.metadata['load_order'].to_i]
      end
    end
    a.sort! { |a,b| a[1] <=> b[1] }
    modules = []
    a.each do |gemspec|
      modules << gemspec[0]
    end
    modules
  end
  #
  # Returns an array of module names
  #
  def self.transam_module_names
    a = []
    self.transam_modules.each do |gem|
      a << gem.name.split('_').last
    end
    a
  end

  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------

  # Returns the default state code. If not defined a nil is returned
  def default_state_code
    # For now get this from the geocoder
    str = geocoder_components
    if str.include? "administrative_area"
      state_code = str.split("|").first.split(":").last
    end
    state_code
  end

  # Returns the first day of the TransAM epoch -- the earliest date which TransAM
  # assumes are valid for assets
  def epoch
    Rails.application.config.epoch
  end

  # The max number of rows to be returned from a query
  def max_rows_returned
    Rails.application.config.max_rows_returned
  end


  def geocoder_bounds
    [[min_lat, min_lon], [max_lat, max_lon]]
  end
  def map_bounds
    [[min_lat, min_lon], [max_lat, max_lon]]
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

end
