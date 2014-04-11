class DocumentUploader < TransamAbstractUploader
        
  def store_dir
    "document_uploads/#{model.object_key}"
  end

  # A white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w( pdf doc docx xls xlsx )
  end

end