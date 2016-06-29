class AddUploadToAssets < ActiveRecord::Migration
  def change
    add_reference :assets, :upload

    change_column :uploads, :organization_id, :integer, :null => true
  end
end
