class AssetSubtype < ActiveRecord::Base

  # Enable auditing of this model type
  has_paper_trail
  
  # Associations
  belongs_to :asset_type
  has_many   :asset_component_types

  attr_accessible :name, :description, :active, :size
  attr_accessible :asset_type_id
  attr_accessible :avg_cost, :avg_life_years 
        
  # default scope
  default_scope where(:active => true)

  def full_name
    "#{name} - #{description}"
  end      
                   
end
      
