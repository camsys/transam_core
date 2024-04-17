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
  SHORT_TON           = 'short ton'
  #TON                 = SHORT_TON
  TONNE               = "tonne"

  # Pre-defined area measurements
  SQUARE_FOOT         = "square foot"
  SQUARE_YARD         = "square yard"
  SQUARE_METER        = "(meter)2"
  SQUARE_MILE         = "square mile"
  ACRE                = "acre"

  # Predefined volumes
  LITER               = "liter"
  GALLON              = "gallon"

  # Pre-defined distance metrics that can be used to define linear distances
  INCH                = 'inch'
  FEET                = 'foot'
  YARD                = 'yard'
  MILE                = 'mile'
  METER               = 'meter'
  KILOMETER           = 'kilometer'

  # predefined weight over distance
  POUND_YARD          = 'lb/yd'
  POUND_INCH          = 'lb/in'
  CUBIC_YARD_MILE     = 'cu yd/mi'


  AREA_UNITS            = [SQUARE_FOOT, SQUARE_YARD, SQUARE_METER, ACRE, SQUARE_MILE]
  DISTANCE_UNITS        = [INCH, FEET, YARD, METER, KILOMETER, MILE]
  VOLUME_UNITS          = [LITER, GALLON]
  WEIGHT_UNITS          = [POUND, KILOGRAM, SHORT_TON, TONNE]
  WEIGHT_DISTANCE_UNITS = [POUND_INCH, POUND_YARD, CUBIC_YARD_MILE]
  OTHER_UNITS     = [UNIT]

  SI_UNITS        = [METER, KILOMETER, SQUARE_METER, LITER, KILOGRAM, TONNE]
  USC_UNITS       = [INCH, FEET, YARD, MILE, SQUARE_FOOT, SQUARE_YARD, ACRE, SQUARE_MILE, GALLON, POUND, SHORT_TON]
  
  # Returns an array of units
  def self.units
    OTHER_UNITS + DISTANCE_UNITS + AREA_UNITS + VOLUME_UNITS + WEIGHT_UNITS
  end

  def self.si_units
    OTHER_UNITS + SI_UNITS
  end

  def self.usc_units
    OTHER_UNITS + USC_UNITS
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
