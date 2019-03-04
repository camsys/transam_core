class AddAutoshowToQueryFields < ActiveRecord::Migration[5.2]
  def change
    add_column :query_fields, :auto_show, :boolean
  end
end
