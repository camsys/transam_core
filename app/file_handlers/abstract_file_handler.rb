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

  # Errors are trapped and handled by the Job that executes this handler
  def execute
    
    # Indicate that processing is starting
    @upload.file_status_type = FileStatusType.find_by_name("In Progress")
    @upload.save
    
    # process the file
    results = process(@upload)
    
    # update the model with the results of the processing
    @upload.processing_log = results[:log]
    @upload.file_status_type = results[:status]
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
