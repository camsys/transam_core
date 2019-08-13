class AddImageClassificationReference < ActiveRecord::Migration[5.2]
  def change
    add_reference :images, :image_classification, index: true
    remove_column :images, :classification
  end
end
