class RemoveUnusedColumnsFromDispositionUpdateEvents < ActiveRecord::Migration
  def change
    if column_exists? :asset_events, :new_owner_name
      remove_column :asset_events, :new_owner_name, :string, :limit => 64
    end
  end
end
