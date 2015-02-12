class RenameActivityScheduleToStart < ActiveRecord::Migration
  def change
    rename_column :activities, :schedule, :start
  end
end
