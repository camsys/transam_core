class AddUploadToAssets < ActiveRecord::Migration
  def change
    add_reference :assets, :upload
  end
end
