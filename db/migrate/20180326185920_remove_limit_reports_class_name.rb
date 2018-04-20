class RemoveLimitReportsClassName < ActiveRecord::Migration
  def change
    change_column :reports, :class_name, :string, :limit => nil
  end
end
