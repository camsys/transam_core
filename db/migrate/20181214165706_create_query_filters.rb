class CreateQueryFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :query_filters do |t|
      t.references :query_field, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
