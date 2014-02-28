class BaseUploader < TransamAbstractUploader
  
  # Choose what kind of storage to use for this uploader:
  storage :file
  #storage :fog

  # Configure the cache folder
  #def cache_dir
  #  "#{Rails.root}/tmp/uploads"
  #end
  
end