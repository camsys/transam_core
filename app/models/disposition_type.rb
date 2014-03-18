class DispositionType < ActiveRecord::Base

  # Enable auditing of this model type
  has_paper_trail

  # associations
  has_many :assets
  
  #attr_accessible :name, :description, :code, :active
        
  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end
  
end
