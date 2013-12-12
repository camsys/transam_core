class PriorityType < ActiveRecord::Base

  # Enable auditing of this model type
  has_paper_trail
            
  attr_accessible :name, :description, :active, :default
        
  # default scope
  default_scope where(:active => true)
  
  def self.default
    where(:default => true).first
  end      

end
