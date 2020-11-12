class AddFileDateAndDocumentTagToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :file_date, :date
    add_reference :documents, :document_tag, foreign_key: true
  end
end
