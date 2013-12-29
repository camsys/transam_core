class ManufacturerModel < ActiveRecord::Base
    
  # every model belongs to a manufacturer
  belongs_to :manufacturer
  
  #attr_accessible :name, :description, :code, :active
        
  # default scope
  default_scope { where(:active => true) }

end

