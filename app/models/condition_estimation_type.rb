class ConditionEstimationType < ActiveRecord::Base
 
  #attr_accessible :name, :description, :class_name, :active
        
  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end
        
end
