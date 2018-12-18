class ChangeQueryFieldCategoryReference < ActiveRecord::Migration[5.2]
  def change
    remove_column :query_fields, :category
    add_column :query_fields, :query_category_id, :integer
    add_index :query_fields, :query_category_id
  end
end
