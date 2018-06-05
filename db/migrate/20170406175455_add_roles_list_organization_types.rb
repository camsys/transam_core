class AddRolesListOrganizationTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :organization_types, :roles, :string, after: :description
  end
end
