
class AssetUpdaterProxy < Proxy
  # General state variables
 
  # Type of asset type to process
  attr_accessor     :asset_types, :asset_groups, :policy
  
  # Basic validations. Just checking that the form is complete
  validates :asset_types, :presence => true 

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
    self.asset_types ||= []
  end
end