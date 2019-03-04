class AddHiddenToQueryFields < ActiveRecord::Migration[5.2]
  def change
    add_column :query_fields, :hidden, :boolean
    remove_column :query_fields, :depends_on, :string
    add_column :query_fields, :pairs_with, :string
  end
end
