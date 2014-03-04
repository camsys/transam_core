#------------------------------------------------------------------------------
#
# AssetConditionUpdateJob
#
# Updates an assets condition
#
#------------------------------------------------------------------------------
class AbstractFileHandler

  attr_accessor :upload
  attr_accessor :errors
  attr_accessor :num_rows_processed
  attr_accessor :num_rows_added
  attr_accessor :num_rows_replaced
  attr_accessor :num_rows_failed
  attr_accessor :new_status
  attr_accessor :processing_log
  
  # Errors are trapped and handled by the Job that executes this handler
  def execute
    
    # Indicate that processing is starting
    @upload.processing_started_at = Time.now
    @upload.file_status_type      = FileStatusType.find_by_name("In Progress")
    @upload.save
    
    # process the file. This method is responsible for setting the results
    process(@upload)
    
    # update the model with the results of the processing
    @upload.file_status_type      = @new_status
    @upload.num_rows_processed    = @num_rows_processed
    @upload.num_rows_added        = @num_rows_added
    @upload.num_rows_replaced     = @num_rows_replaced
    @upload.num_rows_failed       = @num_rows_failed
    
    @upload.processing_log        = @processing_log
    @upload.processing_completed_at = Time.now
    @upload.save
    
  end
  
  def can_process?
    if @upload.nil?
      @errors << "Upload is missing or invalid."
    end
    if @upload.file.url.blank?
      @errors << "File URL can't be blank."      
    end
    # return true or false depending on if errors were generated
    @errors.empty?
  end  
  
  def initialize(*args)
    @errors = []
  end
    
end
