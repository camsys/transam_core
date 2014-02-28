class DocumentUploader < TransamAbstractUploader
        
  def store_dir
    "document_uploads/#{model.object_key}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w( pdf )
  end

end