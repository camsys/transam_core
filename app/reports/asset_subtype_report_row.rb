class AssetSubtypeReportRow < BasicReportRow
  
  attr_accessor :asset_subtype
  
  def initialize(asset_subtype)
    super(asset_subtype)
    self.asset_subtype = asset_subtype
  end

end
