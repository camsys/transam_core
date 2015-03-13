class AbstractReport

  # From the application config
  MAX_FORECASTING_YEARS = SystemConfig.instance.num_forecasting_years
  MAX_REPORTING_YEARS   = SystemConfig.instance.num_reporting_years

  def initialize(attr = {})
    attr.each do |k,v|
      self.send "#{k}=", v if respond_to? k
    end
  end

end
