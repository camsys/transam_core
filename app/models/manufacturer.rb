class Manufacturer < ActiveRecord::Base
  
  # every manufacturuer is specific to an asset class
  belongs_to  :asset_type
    
  # every manufacturer can have 0 or more models
  has_many    :manufacturer_models
  
  #attr_accessible :name, :description, :code, :active
        
  # default scope
  default_scope { where(:active => true) }

end

