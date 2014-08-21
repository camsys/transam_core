class AddReplacementReasonLut < ActiveRecord::Migration
  def change
    # Lookup Tables
    create_table :replacement_reason_types do |t|
      t.string    :name,                :limit => 64, :null => :false
      t.string    :description,                       :null => :false
      t.boolean   :active,                            :null => :false
    end
    
    # Add column to assets and asset events
    add_column :assets,       :replacement_reason_type_id, :integer, :after => :scheduled_by_user
    add_column :asset_events, :replacement_reason_type_id, :integer, :after => :rebuild_year

  end
end
