class LicenseType < ActiveRecord::Base
      
  # associations
  has_many :customers
                
  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end

end
