class ChangeActivityLogActivityToLongText < ActiveRecord::Migration
  def change
    change_column :activity_logs, :activity, :text, :limit => 65536, :default => nil
  end
end
