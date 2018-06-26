class AddSortOrderForms < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :sort_order, :integer, after: :controller
  end
end
