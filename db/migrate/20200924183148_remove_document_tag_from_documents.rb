class RemoveDocumentTagFromDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_column :documents, :document_tag
  end
end
