class DocumentUploader < TransamAbstractUploader
        
  def store_dir
    "document_uploads/#{model.object_key}"
  end

  # A white list of extensions which are allowed to be uploaded.
  def extension_white_list
    if  Rails.application.config.respond_to? :extension_allowed_list
      Rails.application.config.extension_allowed_list
    else
      %w( pdf doc docx xls xlsx ppt )
    end
  end

end