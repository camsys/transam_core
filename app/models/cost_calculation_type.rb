class CostCalculationType < ActiveRecord::Base
          
  # default scope
  default_scope { where(:active => true) }
        
end
