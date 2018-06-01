class RemoveLimitReportsClassName < ActiveRecord::Migration[5.2]
  def change
    change_column :reports, :class_name, :string, :limit => nil
  end
end
