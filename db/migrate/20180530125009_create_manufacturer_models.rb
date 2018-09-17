class CreateManufacturerModels < ActiveRecord::Migration[5.2]
  def change
    create_table :manufacturer_models do |t|
      t.string :name
      t.string :description
      t.references :organization
      t.boolean :active

      t.timestamps
    end
  end
end
