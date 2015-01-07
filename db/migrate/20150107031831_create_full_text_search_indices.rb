class CreateFullTextSearchIndices < ActiveRecord::Migration
  def change
    create_table :full_text_search_indices do |t|
      t.string :object_key
      t.text :search_text

      t.timestamps
    end
  end
end
