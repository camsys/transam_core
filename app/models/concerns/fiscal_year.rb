#-------------------------------------------------------------------------------
#
# FiscalYear
#
# Mixin that adds fiscal year methods to a class
#
#-------------------------------------------------------------------------------
module FiscalYear

  # Returns the date of the start of a fiscal year for a given calendar year. For
  # a year like 2015 we return the start of the FY-15-16 year
  def start_of_fiscal_year date_year
    # System Config provides a string giving the start day of the fiscal year as "mm-dd" eg 07-01 for July 1st. We can
    # append the date year to this and generate the date of the fiscal year starting in the date calendar year
    date_str = "#{SystemConfig.instance.start_of_fiscal_year}-#{date_year}"

    start_of_fiscal_year = Date.strptime(date_str, "%m-%d-%Y")
  end

  # Returns the first day of the planning year which is the next fiscal year
  def start_of_planning_year
    start_of_fiscal_year current_planning_year_year
  end
  # returns the fiscal year epoch -- the first allowable fiscal year for the application
  def fiscal_year_epoch_year
    2010
  end

  def fiscal_year_epoch
    fiscal_year(fiscal_year_epoch_year)
  end
  #
  # Returns the current fiscal year as a calendar year (integer). Each fiscal year is represented as the year in which
  # the fiscal year started, so FY 13-14 would return 2013 as a numeric
  #
  def current_fiscal_year_year
    fiscal_year_year_on_date(Date.today)
  end
  #
  # Returns the current planning year which is always the next fiscal year
  #
  def current_planning_year_year
    current_fiscal_year_year + 1
  end

  # Returns the last fiscal year in the planning horizon
  def last_fiscal_year_year
    current_fiscal_year_year + SystemConfig.instance.num_forecasting_years
  end

  # returns the year for a fiscal year string
  def to_year(fy_str, century = 2000)
    elems = fy_str.split(' ') # split "FY" substring from year

    # get year. returns century if invalid string
    if elems.size == 2
      year = elems.last
    end
    century + year.to_i
  end

  # Returns the fiscal year on a given date
  def fiscal_year_year_on_date(date)

    if date.nil?
      date = Date.today
    end
    date_year = date.year

    # If the start of the fiscal year in the calendar year is before date, we are in the fiscal year that starts in this
    # calendar years, otherwise the date is in the fiscal year that started the previous calendar year
    date < start_of_fiscal_year(date_year) ? date_year - 1 : date_year

  end

  # Returns the end date of the fiscal year of a given date
  def fiscal_year_end_date(date=Date.today)
    date_year = fiscal_year_year_on_date(date)

    # System Config provides a string giving the start day of the fiscal year as "mm-dd" eg 07-01 for July 1st. We can
    # append the date year to this and generate the date of the fiscal year starting in the date calendar year
    date_str = "#{SystemConfig.instance.start_of_fiscal_year}-#{date_year}"

    start_of_fiscal_year = Date.strptime(date_str, "%m-%d-%Y")

    # get end of last fiscal year and add a year for current fiscal year
    start_of_fiscal_year - 1.days + 1.years

  end

  # Returns the current fiscal year as a formatted FY string
  def current_fiscal_year
    fiscal_year(current_fiscal_year_year)
  end

  # Returns the current planning year (the FY after the current one)
  # as a formatted FY string
  def current_planning_year
    fiscal_year(current_planning_year_year)
  end

  # Returns the fiscal year for a date as a formatted FY string
  def fiscal_year_on_date(date)
    fiscal_year(fiscal_year_year_on_date(date))
  end

  # Returns the calendar year formatted as a FY string
  def fiscal_year(year)
    yr = year - fy_century(year)
    first = "%.2d" % yr
    if yr == 99 # when yr == 99, yr + 1 would be 100, which causes: "FY 99-100"
      next_yr = 00
    else
      next_yr = (yr + 1)
    end
    last = "%.2d" % next_yr
    "FY #{first}-#{last}"
  end

  # Returns a select array of fiscal years that includes fiscal years that
  # are before the current fiscal year
  def get_all_fiscal_years
    get_fiscal_years(Date.today - 4.years)
  end

  # Returns a select array of fiscal years
  def get_fiscal_years(date = nil, num_forecasting_years = nil)
    if date
      current_year = fiscal_year_year_on_date(date)
    else
      current_year = current_planning_year_year
    end
    a = []

    # get last fiscal year from current year and num of forecasting years
    if num_forecasting_years.nil?
      last_year = last_fiscal_year_year
    else
      last_year = current_fiscal_year_year + num_forecasting_years
    end

    (current_year..last_year).each do |year|
      a << [fiscal_year(year), year]
    end
    a
  end

  # Returns a select array of fiscal years remaining in the planning period
  def get_planning_fiscal_years(date = Date.today)
    current_year = fiscal_year_year_on_date(date)
    a = []
    (current_year..last_fiscal_year_year).each do |year|
      a << [fiscal_year(year), year]
    end
    a
  end

  # Determines the century for the year. Assumes assets are no older than 1900
  def fy_century(fy)
    fy < 2000 ? 1900 : 2000
  end

end
