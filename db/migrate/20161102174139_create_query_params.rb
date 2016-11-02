class CreateQueryParams < ActiveRecord::Migration
  def change
    create_table :query_params do |t|
      t.string :name
      t.string :description
      t.text :query_string
      t.string :class_name
      t.boolean :active

    end
  end
end
