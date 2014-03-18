class Customer < ActiveRecord::Base

  #associations
  belongs_to  :license_type
  has_one     :license_holder, :class_name => 'Organization', :conditions => 'license_holder = true'
  has_many    :organizations
  has_many    :users
    
  #attr_accessible :license_type_id, :active
    
  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end
  
end
      
