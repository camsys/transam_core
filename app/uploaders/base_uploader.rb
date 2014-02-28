class BaseUploader < TransamAbstractUploader
  
  # Choose what kind of storage to use for this uploader:
  storage :file
  #storage :fog
  
end