class AddRolesListOrganizationTypes < ActiveRecord::Migration
  def change
    add_column :organization_types, :roles, :string, after: :description
  end
end
