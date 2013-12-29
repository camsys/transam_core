class AssetType < ActiveRecord::Base
        
  # associations
  
  # every asset type has 0 or more sub types
  has_many :asset_subtypes

  # every asset type has 0 or more manufacturers
  has_many :manufacturers
  
  #attr_accessible :name, :description, :active
  #attr_accessible :class_name, :form_name, :index_name
  #attr_accessible :map_icon_name, :display_icon_name
  
  # default scope
  default_scope { where(:active => true) }
  
  def full_name
    "#{name} - #{description}"
  end      
end
