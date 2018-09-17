class AddMeasurementSystemSystemConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :system_configs, :measurement_system, :string, after: :special_locked_fields
  end
end
