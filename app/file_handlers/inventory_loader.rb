#------------------------------------------------------------------------------
#
# InventoryLoader
#
# Abstract base class for a loader. Provides errors, warnings, lists, coercion
# methods etc. All spreadsheet loaders should derive from this.
#
#------------------------------------------------------------------------------
class InventoryLoader
  
  def notes?
    @notes.count > 0 
  end  
  
  def warnings?
    @warnings.count > 0 
  end  
  def errors?
    @errors.count > 0 
  end
  def notes
    @notes
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
    return false if cell_val.blank?
    return cell_val.to_s.start_with?("Y", "y")
  end

  def as_year(cell_val)
    #Rails.logger.debug "Converting  to year '#{cell_val}'"
    val = as_integer(cell_val)
    if val < 50 
      val += 2000
    end
    val
  end
  
  def as_date(cell_val)
    if is_a?(Date)
      val = cell_val
    else
      val = 0.0
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

  def as_integer(cell_val)    # Check to see if the spreadsheet encoded this as a number
    #Rails.logger.debug "Converting to integer '#{cell_val}'"
    if is_number?(cell_val)
      val = cell_val.to_i
    else
      val = 0
    end
    val
  end
  
  def as_string(cell_val)
    # Check to see if the spreadsheet encoded this as a number
    if cell_val.is_a?(Float)
      # convert it first to an int to remove the decimal point then to the string
      val = cell_val.to_i.to_s
    else
      val = cell_val
    end
    
    val
  end
    
  # Return the manufacturer for the asset, if not found, Unknown is returned
  def get_manufacturer(manufacturer_str, is_rail)
    filter = is_rail ? "rail" : "non-rail"
    result = Manufacturer.where('filter = ? AND code = ? OR name = ?', filter, manufacturer_str, manufacturer_str).first
    if result.nil?
      result = Manufacturer.where('filter = ? AND name = ?', filter, @Unknown).first
    end
    result
  end

  
  private
  
  def initialize
    @warnings = []
    @errors   = []
    @notes    = []
  end
  
end