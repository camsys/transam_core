class AddTimeEpochToSystemConfig < ActiveRecord::Migration
  def change
    add_column :system_configs, :time_epoch, :date, :after => :data_file_path
  end
end
