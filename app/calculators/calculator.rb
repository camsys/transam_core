#------------------------------------------------------------------------------
#
# Base class for all TransAM calculators. Each instance of this class must provide 
# a calculate(asset) method.
#
#------------------------------------------------------------------------------

class Calculator
  
  def initialize(policy)
    @policy = policy
  end

  # All class instances should override this method to return a calculated value for the asset 
  def calculate(asset)
    nil
  end  
 
end