#------------------------------------------------------------------------------
#
# FiscalYear
#
# Mixin that adds a fiscal year methods to a class
#
#------------------------------------------------------------------------------
module FiscalYear

  #
  # Returns the current fiscal year as a calendar year (integer). Each fiscal year is represented as the year in which
  # the fiscal year started, so FY 13-14 would return 2013 as a numeric
  #
  def current_fiscal_year_year
    
    # System Config provides a string giving the start day of the fiscal year as "mm-dd" eg 07-01 for July 1st
   
    # Get the start day of the fiscal year starting in this calendar year. This function will use the current
    # year as the date year
    start_of_fiscal_year = Date.strptime(SystemConfig.start_of_fiscal_year, "%m-%d")
    
    # If the start of the fiscal year in this calendar year is after today, we are in the current fiscal year
    # otherwise we are still in the fiscal year that started last calendar year
    today = Date.today
    today.year < start_of_fiscal_year ? today.year - 1 : today.year
  end
  
  # Returns the current fiscal year as a formatted string
  def current_fiscal_year
    current_year = current_fiscal_year_year
    "FY #{current_year}-#{current_year+1}"
  end
  
end
