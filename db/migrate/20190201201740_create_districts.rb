class CreateDistricts < ActiveRecord::Migration[5.2]
  def change
    unless ActiveRecord::Base.connection.table_exists? 'districts'
      create_table :districts do |t|
        t.references :district_type
        t.string :name, limit: 64, null: false
        t.string :code, null: false
        t.string :description, limit: 254, null: false
        t.boolean :active, null: false
      end
      add_index :districts, :name
      add_index :districts, :code
    end
  end
end
