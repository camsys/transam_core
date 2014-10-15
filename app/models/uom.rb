#
# Simple lookup class for distance metrics. Maybe used to add different 
# measurement units as needed.
#
# This implementation wraps Unitwise but always extend this model rather
# than using Unitwise directly
#
#
class Uom
  
  # Pre-defined distance metrics that can be used to define linear distances
  INCH                = 'inch'
  FEET                = 'foot'
  YARD                = 'yard'
  MILE                = 'mile'
  METER               = 'meter'
  KILOMETER           = 'kilometer'
  
  # Check to see if a measurement unit is valid
  def self.valid? uom
    Unitwise.valid? uom
  end
  
  # Convert a quantity from one unit to another
  def self.convert(quantity, from_uom, to_uom)
    begin
      Unitwise(quantity, from_uom).convert_to(to_uom).to_f
    rescue Exception
      raise ArgumentError.new('invalid argument')
    end
  end
  
end