class AddAgencyOfficeAddressToOrganization < ActiveRecord::Migration[5.2]
  def change
  	add_column :organizations, :agency_office_address, :string
  end
end
