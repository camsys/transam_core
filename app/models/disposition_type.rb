class DispositionType < ActiveRecord::Base

  # associations
  has_many :assets
  
  #attr_accessible :name, :description, :code, :active
        
  # default scope
  default_scope { where(:active => true) }

  def self.search(text, exact = true)
    if exact
      x = where('name = ? OR code = ? OR description = ?', text, text, text).first
    else
      val = "%#{text}%"
      x = where('name = LIKE ? OR code LIKE ? OR description LIKE ?', val, val, val).first
    end
    x
  end

  def to_s
    name
  end
  
end
