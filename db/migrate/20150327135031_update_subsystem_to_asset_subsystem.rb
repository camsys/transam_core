class UpdateSubsystemToAssetSubsystem < ActiveRecord::Migration
  def change
    rename_table :subsystems, :asset_subsystems
    rename_table :asset_event_subsystems, :asset_event_asset_subsystems

    rename_column :asset_event_asset_subsystems, :subsystem_id, :asset_subsystem_id

    add_column :asset_subsystems, :active, :boolean, :after => :asset_type_id
    add_column :asset_subsystems, :code, :string, :limit => 2, :after => :name
    add_column :asset_subsystems, :description, :string, :limit => 254, :after => :code
  end
end
