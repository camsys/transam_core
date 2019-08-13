class CreateImageClassifications < ActiveRecord::Migration[5.2]
  def change
    create_table :image_classifications do |t|
      t.string :name
      t.string :category
      t.boolean :active

      t.timestamps
    end
  end
end
