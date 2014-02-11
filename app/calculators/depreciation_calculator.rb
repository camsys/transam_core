#------------------------------------------------------------------------------
#
# Base class for calculating asset depreciatio
#
#------------------------------------------------------------------------------
class DepreciationCalculator < Calculator
    
  def basis(asset)
    # Get the basis for the depreciation as the purchase price minus the residual value at
    # the end of the asset's useful life
    purchase_cost(asset) - residual_value(asset)    
  end  
  
  def residual_value(asset)
    purchase_cost(asset) * (asset.asset_subtype.pcnt_residual_value / 100.0)
  end

  def purchase_cost(asset)
    asset.purchase_cost
  end
  
end