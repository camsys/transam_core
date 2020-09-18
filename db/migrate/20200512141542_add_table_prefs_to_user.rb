class AddTablePrefsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :table_prefs, :text
  end
end
