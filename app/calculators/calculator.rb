#------------------------------------------------------------------------------
#
# Base class for all TransAM calculators. Each instance of this class must provide
# a calculate(asset) method.
#
#------------------------------------------------------------------------------

class Calculator

  # Include the fiscal year mixin
  include FiscalYear

  INFINITY = 999999999.9

  # All class instances should override this method to return a calculated value for the asset
  def calculate(asset)
    nil
  end

end
