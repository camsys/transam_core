class RolePrivilegeMapping < ActiveRecord::Base
  belongs_to :role
  belongs_to :privilege, class_name: 'Role'

  #---------------------------------------------------------------------------
  # Validations
  #---------------------------------------------------------------------------

  validates    :privilege_id,  :presence => true, :allow_nil => false, :uniqueness => { :scope => :role_id}
  validates    :role_id,          :presence => true, :allow_nil => false, :uniqueness => { :scope => :organization_id}

  #---------------------------------------------------------------------------
  # Class Methods
  #---------------------------------------------------------------------------

  # { org_id => role_id_array}, e.g. {1 => [1, 8, 9]}
  def self.role_ids_by_privilege
    RolePrivilegeMapping.pluck(:privilege_id, :role_id).each_with_object({}) { |(f,l),h|  h.update(f=>[l]) {|_,ov,nv| ov+nv }}
  end

  # { role_id => org_id_array}, e.g. {1 => [1, 8, 9]}
  def self.privilege_ids_by_role
    RolePrivilegeMapping.pluck(:role_id, :privilege_id).each_with_object({}) { |(f,l),h|  h.update(f=>[l]) {|_,ov,nv| ov+nv }}
  end
end
