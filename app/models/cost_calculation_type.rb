class CostCalculationType < ActiveRecord::Base
  
  # associations
  has_many :policys

  #attr_accessible :name, :description, :class_name, :active
        
  # default scope
  default_scope where(:active => true)
        
end
