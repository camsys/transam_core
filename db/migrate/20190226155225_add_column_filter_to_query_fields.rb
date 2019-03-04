class AddColumnFilterToQueryFields < ActiveRecord::Migration[5.2]
  def change
    add_column :query_fields, :column_filter, :string
    add_column :query_fields, :column_filter_value, :string
  end
end
