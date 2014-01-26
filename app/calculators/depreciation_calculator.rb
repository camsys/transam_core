#------------------------------------------------------------------------------
#
# Base class for calculating asset depreciatio
#
#------------------------------------------------------------------------------
class DepreciationCalculator < Calculator
    
  protected

  def basis(asset)
    # Get the basis for the depreciation as the purchase price minus the residual value at
    # the end of the asset's useful life
    purchase_price(asset) - residual_value(asset)    
  end  
  
  def residual_value(asset)
    purchase_price(asset) * (asset.asset_subtype.pcnt_residual_value / 100.0)
  end

  def purchase_price(asset)
    asset.purchase_price
  end
  
end