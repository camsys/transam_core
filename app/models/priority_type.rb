class PriorityType < ActiveRecord::Base
            
  #attr_accessible :name, :description, :active, :default
        
  # default scope
  default_scope { where(:active => true) }
  
  def self.default
    where(:default => true).first
  end      

end
