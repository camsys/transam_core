class LicenseType < ActiveRecord::Base
      
  # associations
  has_many :customers
        
  #attr_accessible :sign_manager, :web_services  
  #attr_accessible :name, :description, :code, :active
        
  # default scope
  default_scope where(:active => true)

end
