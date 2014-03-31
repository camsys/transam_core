class ConditionEstimationCalculator < Calculator
  
  # All class instances should override this method to return the projected last year for an asset 
  def last_year(asset)
    nil
  end  

  # determine the slope between two points
  def slope(x1, y1, x2, y2)
    dx = x2 - x1
    dy = y2 - y1
    if dy.abs < 0.0001
     0.0
    elsif dx.abs < 0.0001
      -1.0
    else
      dy / dx
    end
  end
  
end