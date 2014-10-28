#------------------------------------------------------------------------------
#
# NumericSanitizers
#
# Mixin that adds numeric sanitizers to a model
#
#------------------------------------------------------------------------------
module TransamNumericSanitizers
  extend ActiveSupport::Concern

  included do

  end

  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
  module ClassMethods
  
  end
  #------------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #------------------------------------------------------------------------------


  # Strip extraneous non-numeric characters from an input number and return a float
  def sanitize_to_float(num)
    num.to_s.gsub('$%\'"','').scan(/\b-?[\d.]+/).join.to_f
  end
  
  # Strip extraneous non-numeric characters from an input number and return a float
  def sanitize_to_int(num)
    sanitize_to_float(num).to_i
  end

end
