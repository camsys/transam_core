class CreateRehabUpdateTables < ActiveRecord::Migration
  def change
    create_table :subsystems do |t|
      t.string  :name,  :limit => 64, :null => :false
      t.references :asset_type
    end

    create_table :asset_event_subsystems do |t|
      t.references :asset_event
      t.references :subsystem
      t.integer    :parts_cost
      t.integer    :labor_cost
    end

    add_index     :asset_event_subsystems, :asset_event_id, :name => :rehab_events_subsystems_idx1
    add_index     :asset_event_subsystems, :subsystem_id,   :name => :rehab_events_subsystems_idx2

    add_column :asset_events :extended_useful_life_months, :integer, :after => :disposition_year
    add_column :asset_events :extended_useful_life_miles, :integer, :after => :disposition_year
  end
end
