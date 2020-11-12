class CreateDocumentFolders < ActiveRecord::Migration[5.2]
  def change
    create_table :document_folders do |t|
      t.string :name
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end
