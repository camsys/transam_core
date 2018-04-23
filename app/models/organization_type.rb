class OrganizationType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }
  
  def to_s
    name
  end

  # used in the user form interface to determine the types of users for that org type
  def role_mappings
    Role.where(name: roles.split(','))
  end
end
