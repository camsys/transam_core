class NewInventoryFileHandler < AbstractFileHandler
  
  # Perform the processing
  def process(upload)
    
    file_url = upload.file.url
          
    @new_status = FileStatusType.find_by_name("Complete")
    @num_rows_processed = 0
    @num_rows_added = 0
    @num_rows_replaced = 0
    @num_rows_failed = 0
    @processing_log = "Process complete"
    
  end
  
  # Init
  def initialize(upload)
    super
    self.upload = upload
  end
  
end