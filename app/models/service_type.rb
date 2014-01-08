class ServiceType < ActiveRecord::Base

  has_and_belongs_to_many :organizations
        
  # default scope
  default_scope { where(:active => true) }
              
end
