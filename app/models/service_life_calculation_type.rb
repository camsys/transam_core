class ServiceLifeCalculationType < ActiveRecord::Base
        
  #attr_accessible :name, :description, :active, :class_name
        
  # default scope
  default_scope { where(:active => true) }

end
