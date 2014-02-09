class LocationType < ActiveRecord::Base

  # associations
  has_many :locations
          
  # default scope
  default_scope { where(:active => true) }
  
end
