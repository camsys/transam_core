class AddLegalNameToOrganizations < ActiveRecord::Migration[5.2]
  def up
    add_column :organizations, :legal_name, :string

    Organization.all.each do |o|
      o.update(legal_name: o.name)
    end
  end
  def down
    remove_column :organizations, :legal_name
  end
end
