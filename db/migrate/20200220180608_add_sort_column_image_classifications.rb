class AddSortColumnImageClassifications < ActiveRecord::Migration[5.2]
  def change
    add_column :image_classifications, :sort_order, :integer, after: :category
  end
end
