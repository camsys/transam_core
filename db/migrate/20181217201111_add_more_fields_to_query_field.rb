class AddMoreFieldsToQueryField < ActiveRecord::Migration[5.2]
  def change
    add_column :query_fields, :depends_on, :string
    add_column :query_fields, :filter_type, :string
  end
end
