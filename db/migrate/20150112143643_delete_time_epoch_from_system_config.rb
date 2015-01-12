class DeleteTimeEpochFromSystemConfig < ActiveRecord::Migration
  def change
    remove_column :system_configs, :time_epoch
  end
end
