class LocationReferenceType < ActiveRecord::Base

  #attr_accessible :name, :format, :description, :active
        
  # default scope
  default_scope { where(:active => true) }
              
end
