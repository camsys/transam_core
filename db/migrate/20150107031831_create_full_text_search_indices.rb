class CreateFullTextSearchIndices < ActiveRecord::Migration

  def up
    create_table :full_text_search_indices do |t|
      t.string :object_key
      t.string :object_class
      t.string :context
      t.text :search_text

      t.timestamps
    end
  end

  def down
  	drop_table :full_text_search_indices
  end
  
end
