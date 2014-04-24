#------------------------------------------------------------------------------
#
# NumericSanitizers
#
# Mixin that adds numeric sanitizers to a model
#
#------------------------------------------------------------------------------
module NumericSanitizers

  # Strip extraneous non-numeric characters from an input number and return a float
  def sanitize_to_float(num)
    num.to_s.scan(/\b-?[\d.]+/).join.to_f
  end
  # Strip extraneous non-numeric characters from an input number and return a float
  def sanitize_to_int(num)
    num.to_s.scan(/\b-?[\d.]+/).join.to_i
  end

end
