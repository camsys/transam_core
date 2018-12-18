class CreateQueryFields < ActiveRecord::Migration[5.2]
  def change
    create_table :query_fields do |t|
      t.string :name
      t.string :label
      t.string :category
      t.timestamps
    end
  end
end
