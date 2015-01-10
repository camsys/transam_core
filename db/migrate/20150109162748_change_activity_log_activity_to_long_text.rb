class ChangeActivityLogActivityToLongText < ActiveRecord::Migration
  def change
    change_column :activity_logs, :activity, :text, :limit => 2147483647
  end
end
