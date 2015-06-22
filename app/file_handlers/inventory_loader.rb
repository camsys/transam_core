#------------------------------------------------------------------------------
#
# InventoryLoader
#
# Abstract base class for a loader. Provides errors, warnings, lists, coercion
# methods etc. All spreadsheet loaders should derive from this.
#
#------------------------------------------------------------------------------
class InventoryLoader

  attr_accessor :upload

  def comments?
    @comments.count > 0
  end

  def warnings?
    @warnings.count > 0
  end
  def errors?
    @errors.count > 0
  end
  def comments
    @comments
  end

  def warnings
    @warnings
  end

  def errors
    @errors
  end

  protected

  def is_number?(val)
    Float(val) != nil rescue false
  end

  def as_boolean(cell_val)
    if cell_val.blank?
      false
    else
      (cell_val.to_s.start_with?("Y", "y", "T", "t"))
    end
  end

  def as_year(cell_val)
    #Rails.logger.debug "Converting  to year '#{cell_val}'"
    val = as_integer(cell_val)
    if val < 50
      val += 2000
    end
    val
  end

  # Roo parses date and datetime formatted cells to the corresponding class
  # so we check to see if they are already processed otherwise we attempt
  # to parse the string value
  def as_date(cell_val)
    # Check to see if the spreadsheet encoded this as a number
    if cell_val.is_a?(Date)
      val = cell_val
    elsif
      cell_val.is_a?(DateTime)
      val = cell_val.date
    else
      # parse the string as a date
      val = coerce_date(cell_val.to_s)
    end
    val
  end

  def as_float(cell_val)
    if is_number?(cell_val)
      val = cell_val.to_f
    else
      val = 0.0
    end
    val
  end

  def as_integer(cell_val)
    val = as_float(cell_val) + 0.5
    val.to_i
  end

  def as_string(cell_val)
    # Check to see if the spreadsheet encoded this as a number
    #if cell_val.is_a?(Float)
      # convert it first to an int to remove the decimal point then to the string
    #  val = cell_val.to_i.to_s
    #else
      val = cell_val.to_s
    #end

    val
  end

  # Return the manufacturer for the asset, if not found, Unknown is returned
  def get_manufacturer(manufacturer_str, asset)
    # See if we can get a correct hit
    result = Manufacturer.where('filter = ? AND (code = ? OR name = ?)', asset.class.name, manufacturer_str, manufacturer_str).first
    # Nothing so try matching the start of the name
    if result.nil?
      result = Manufacturer.where('filter = ? AND name LIKE ?', asset.class.name, "#{manufacturer_str}%").first
    end
    # Still nothing! Default to class unknown
    if result.nil?
      result = Manufacturer.where('filter = ? AND name = ?', asset.class.name, "Unknown").first
    end
    result
  end

  protected

  # Attempts to coerce a string containing an excel formatted date back into a
  # Ruby date
  def coerce_date(val)
    #puts "coerce_date: '#{val}'"
    # If there is no date, dont try to set one
    if val.blank?
      return nil
    end

    #strip date first
    val.strip!

    # Pull the date apart and try to determine what is there
    elems = val.split('/')
    # check for just a year and set it to the first day of the fiscal year
    if elems.size == 1
      date_str = "#{SystemConfig.instance.start_of_fiscal_year}-#{elems[0]}"
      d = Date.strptime(date_str, "%m-%d-%Y")
    elsif elems.last.length == 2
      d = Date.strptime(val, "%m/%d/%y")
    else
      d = Date.strptime(val, "%m/%d/%Y")
    end
    #puts d
    d
  end

  private

  def initialize
    @warnings = []
    @errors   = []
    @comments = []
  end

end
