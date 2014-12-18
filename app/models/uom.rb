#
# Simple lookup class for distance metrics. Maybe used to add different
# measurement units as needed.
#
# This implementation wraps Unitwise but always extend this model rather
# than using Unitwise directly
#
#
class Uom

  # Other units
  UNIT                = 'unit'

  # Pre-defined weight quantities
  KILOGRAM            = 'kilogram'
  POUND               = "pound"
  SHORT_TON           = 'short_ton'
  TON                 = SHORT_TON
  TONNE               = "tonne"

  # Pre-defined area measurements
  SQUARE_FOOT         = "square foot"
  SQUARE_YARD         = "square yard"
  SQUARE_METER        = "square meter"
  SQUARE_MILE         = "square mile"
  ACRE                = "acre"

  # Predefined volumes
  LITRE               = "litre"
  GALLON              = "gallon"

  # Pre-defined distance metrics that can be used to define linear distances
  INCH                = 'inch'
  FEET                = 'foot'
  YARD                = 'yard'
  MILE                = 'mile'
  METER               = 'meter'
  KILOMETER           = 'kilometer'

  AREA_UNITS      = [SQUARE_FOOT, SQUARE_YARD, SQUARE_METER, SQUARE_MILE, ACRE]
  DISTANCE_UNITS  = [INCH, FEET, YARD, MILE, METER, KILOMETER]
  VOLUME_UNITS    = [LITRE, GALLON]
  WEIGHT_UNITS    = [KILOGRAM, POUND, TONNE, SHORT_TON, TON]
  OTHER_UNITS     = [UNIT]

  # Returns an array of units
  def self.units
    OTHER_UNITS + AREA_UNITS + DISTANCE_UNITS + VOLUME_UNITS + WEIGHT_UNITS
  end
  
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
