class AssetSubtype < ActiveRecord::Base

  # Associations
  belongs_to :asset_type

  #attr_accessible :name, :description, :active, :size
  #attr_accessible :asset_type_id
  #attr_accessible :avg_cost, :avg_life_years
  #attr_accessible :pcnt_residual_value 
        
  # default scope
  default_scope { where(:active => true) }

  def full_name
    "#{name} - #{description}"
  end      
                   
end
      
