class MoveTransitFieldsTransamAssets < ActiveRecord::Migration[5.2]
  def change
    remove_column :transam_assets, :operator_id
    remove_column :transam_assets, :other_operator
    remove_column :transam_assets, :title_number
    remove_column :transam_assets,:title_ownership_organization_id
    remove_column :transam_assets, :other_title_ownership_organization
    remove_column :transam_assets, :lienholder_id
    remove_column :transam_assets, :other_lienholder
  end
end
