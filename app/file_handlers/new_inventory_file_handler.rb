class NewInventoryFileHandler < AbstractFileHandler
  
  # Perform the processing
  def process(upload)
    
    file_url = upload.file.url
      
    new_status = FileStatusType.find_by_name("Complete")
    processing_log = "Process complete"
    
    # Return the results
    {:status => new_status, :log => processing_log}
  end

  
  # Init
  def initialize(upload)
    super
    self.upload = upload
  end
  
end