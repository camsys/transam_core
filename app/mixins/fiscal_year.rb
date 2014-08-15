#------------------------------------------------------------------------------
#
# FiscalYear
#
# Mixin that adds a fiscal year methods to a class
#
#------------------------------------------------------------------------------
module FiscalYear

  MAX_FORECASTING_YEARS = SystemConfig.instance.num_forecasting_years   

  #
  # Returns the current fiscal year as a calendar year (integer). Each fiscal year is represented as the year in which
  # the fiscal year started, so FY 13-14 would return 2013 as a numeric
  #
  def current_fiscal_year_year
    fiscal_year_year_on_date(Date.today)
  end
  
  # Returns the last fiscal year in the planning horizon
  def last_fiscal_year_year
    current_fiscal_year_year + MAX_FORECASTING_YEARS - 1
  end

  # returns the year for a fiscal year string
  def to_year(fiscal_year)
    elems = fiscal_year.split('0')
    if elems.size == 2
      year = 2000 + elems[0].split(' ').last.to_i
    else
      nil
    end
  end
  
  # Returns the fiscal year on a given date
  def fiscal_year_year_on_date(date)

    if date.nil?
      date = Date.today
    end
    date_year = date.year
    
    # System Config provides a string giving the start day of the fiscal year as "mm-dd" eg 07-01 for July 1st. We can
    # append the date year to this and generate the date of the fiscal year starting in the date calendar year
    date_str = "#{SystemConfig.instance.start_of_fiscal_year}-#{date_year}"
    
    start_of_fiscal_year = Date.strptime(date_str, "%m-%d-%Y")
    
    # If the start of the fiscal year in the calendar year is before date, we are in the fiscal year that starts in this
    # calendar years, otherwise the date is in the fiscal year that started the previous calendar year
    date < start_of_fiscal_year ? date_year - 1 : date_year
    
  end  
  
  # Returns the current fiscal year as a formatted FY string
  def current_fiscal_year
    fiscal_year(current_fiscal_year_year)
  end

  # Returns the fiscal year for a date as a formatted FY string
  def fiscal_year_on_date(date)
    fiscal_year(fiscal_year_year_on_date(date))
  end
  
  # Returns the calendar year formatted as a FY string
  def fiscal_year(year)
    yr = year - 2000
    "FY #{yr}-#{yr+1}"    
  end

  # Returns a select array of fiscal years
  def get_fiscal_years(date = Date.today)
    current_year = fiscal_year_year_on_date(date)
    a = []
    (current_year..last_fiscal_year_year).each do |year|
      a << [fiscal_year(year), year]
    end
    a
  end

end
