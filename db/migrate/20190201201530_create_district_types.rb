class CreateDistrictTypes < ActiveRecord::Migration[5.2]
  def change
    unless ActiveRecord::Base.connection.table_exists? 'district_types'
      create_table :district_types do |t|
        t.string :name, limit: 64, null: false
        t.string :description, limit: 254, null: false
        t.boolean :active, null: false
      end
    end
  end
end
