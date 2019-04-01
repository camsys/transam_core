class AddCountryToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :country, :string
  end
end
