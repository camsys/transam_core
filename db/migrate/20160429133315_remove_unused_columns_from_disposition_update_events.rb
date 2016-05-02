class RemoveUnusedColumnsFromDispositionUpdateEvents < ActiveRecord::Migration
  def change
    remove_column :asset_events, :new_owner_name, :string, :limit => 64
  end
end
