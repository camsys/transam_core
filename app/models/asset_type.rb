class AssetType < ActiveRecord::Base
        
  # associations
  
  # every asset type has 0 or more sub types
  has_many :asset_subtypes

  # every asset type has 0 or more manufacturers
  has_and_belongs_to_many :manufacturers
    
  # default scope
  default_scope { where(:active => true) }
  
  def full_name
    "#{name} - #{description}"
  end      
end
