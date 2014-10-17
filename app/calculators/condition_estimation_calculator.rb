class ConditionEstimationCalculator < Calculator

  # determine the slope between two points
  def slope(x1, y1, x2, y2)
    dx = x2 - x1
    dy = y2 - y1

    if dy.abs < 0.0001
     0.0
    elsif dx.abs < 0.0001
      -1.0
    else
      dy.to_f / dx.to_f
    end
  end

end
