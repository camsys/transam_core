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

  def to_s
    name
  end
  
  def self.search(text, exact = true)
    if exact
      x = where('name = ? OR code = ? OR description = ?', text, text, text).first
    else
      val = "%#{text}%"
      x = where('name = LIKE ? OR code LIKE ? OR description LIKE ?', val, val, val).first
    end
    x
  end
  
end
