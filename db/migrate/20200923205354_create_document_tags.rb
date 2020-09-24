class CreateDocumentTags < ActiveRecord::Migration[5.2]
  def change
    create_table :document_tags do |t|
      t.string :name
      t.text :description
      t.string :pattern
      t.string :allowed_extensions
      t.references :document_folder, index: true
      t.boolean :active

      t.timestamps
    end
  end
end
