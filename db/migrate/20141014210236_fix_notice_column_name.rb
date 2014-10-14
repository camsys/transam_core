class FixNoticeColumnName < ActiveRecord::Migration
  def change
    rename_column :notices, :summmary, :summary
  end
end
