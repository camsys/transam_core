class AddUploadIdTransamAssets < ActiveRecord::Migration[5.2]
  def change
    add_reference :transam_assets, :upload, after: :asset_subtype_id
  end
end
