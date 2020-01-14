class ParentTransamAssetsView < ActiveRecord::Base
  self.table_name = :parent_transam_assets_view
  self.primary_key = :parent_id

  def readonly?
    true
  end

end