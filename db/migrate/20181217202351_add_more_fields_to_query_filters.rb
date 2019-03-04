class AddMoreFieldsToQueryFilters < ActiveRecord::Migration[5.2]
  def change
    add_column :query_filters, :op, :string
  end
end
