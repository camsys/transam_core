class ExcelUploader < TransamAbstractUploader

  def store_dir
    "file_uploads/#{model.object_key}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(xls xlsx csv)
  end

end