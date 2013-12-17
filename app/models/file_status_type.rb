class FileStatusType < ActiveRecord::Base
    
  #attr_accessible :name, :description, :code, :active
        
  # default scope
  default_scope { where(:active => true) }

end

