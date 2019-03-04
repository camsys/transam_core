class CreateSavedQueryFields < ActiveRecord::Migration[5.2]
  def change
    create_table :saved_query_fields do |t|
      t.references :saved_query, foreign_key: true
      t.references :query_field, foreign_key: true

      t.timestamps
    end
  end
end
