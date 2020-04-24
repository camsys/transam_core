class CreateRolePrivilegeMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :role_privilege_mappings do |t|
      t.references :role
      t.references :privilege
    end
  end
end
