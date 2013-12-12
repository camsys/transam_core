class OrganizationType < ActiveRecord::Base
  
  attr_accessible :class_name
  attr_accessible :name, :description, :active, :display_icon_name
        
  # default scope
  default_scope where(:active => true)
  
end