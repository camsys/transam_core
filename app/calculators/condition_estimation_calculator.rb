class ConditionEstimationCalculator < Calculator
  
  # All class instances should override this method to return the projected last year for an asset 
  def last_year(asset)
    nil
  end  

  # determine the slope between two points
  def slope(x1, y1, x2, y2)
    (y2 - y1) / (x2 - x1)
  end
  
end