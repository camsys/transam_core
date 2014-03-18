class FileContentType < ActiveRecord::Base
  
  # Enable auditing of this model type
  has_paper_trail

  #attr_accessible :name, :description, :active
        
  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end

end

