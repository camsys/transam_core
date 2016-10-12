class OrganizationRoleMapping < ActiveRecord::Base

  #---------------------------------------------------------------------------
  # Validations
  #---------------------------------------------------------------------------

  validates    :organization_id,  :presence => true, :allow_nil => false, :uniqueness => { :scope => :role_id}
  validates    :role_id,          :presence => true, :allow_nil => false, :uniqueness => { :scope => :organization_id}

  #---------------------------------------------------------------------------
  # Class Methods
  #---------------------------------------------------------------------------
  
  # { org_id => role_id_array}, e.g. {1 => [1, 8, 9]}
  def self.role_ids_by_org
    @org_role_ids ||= OrganizationRoleMapping.pluck(:organization_id, :role_id).each_with_object({}) { |(f,l),h|  h.update(f=>[l]) {|_,ov,nv| ov+nv }}
    
    @org_role_ids
  end

  # { role_id => org_id_array}, e.g. {1 => [1, 8, 9]}
  def self.org_ids_by_role
    @role_org_ids ||= OrganizationRoleMapping.pluck(:role_id, :organization_id).each_with_object({}) { |(f,l),h|  h.update(f=>[l]) {|_,ov,nv| ov+nv }}
    
    @role_org_ids
  end
end
