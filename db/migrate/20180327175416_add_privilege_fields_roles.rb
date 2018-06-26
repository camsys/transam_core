class AddPrivilegeFieldsRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :role_parent_id, :integer, after: :resource_type
    add_column :roles, :show_in_user_mgmt, :boolean, after: :role_parent_id
  end
end
