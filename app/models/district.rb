class District < ActiveRecord::Base

  # Enable auditing of this model type
  has_paper_trail
            
  # Associations
  belongs_to :district_type
  
  #attr_accessible :name, :description, :district_type_id, :active
    
    
  validates :name,              :presence => true
  validates :code,              :presence => true, :uniqueness => true
  validates :description,       :presence => true
  validates :district_type_id,  :presence => true
    
  # default scope
  default_scope { where(:active => true) }
  
end
