class DistrictType < ActiveRecord::Base

  has_many :districts
  
  #attr_accessible :name, :description, :active
        
  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end
  
end
