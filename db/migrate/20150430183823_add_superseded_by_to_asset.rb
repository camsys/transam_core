class AddSupersededByToAsset < ActiveRecord::Migration
  def change
    add_column    :assets, :superseded_by_id, :integer, :after => :parent_id

    add_index :assets,   :superseded_by_id,   :name => :assets_idx13

  end
end
