class ChangeQueryFilterValueType < ActiveRecord::Migration[5.2]
  def change
    change_column :query_filters, :value, :text
  end
end
