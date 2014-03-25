#------------------------------------------------------------------------------
#
# AbstractFileHandler
#
# Base class for file handlers
#
#------------------------------------------------------------------------------
class AbstractFileHandler
  
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
    @upload.num_rows_skipped      = @num_rows_skipped
    
    @upload.processing_log        = @process_log.join('')
    @upload.processing_completed_at = Time.now
    @upload.save
    
  end
  
  def can_process?
    if @upload.nil?
      @process_log << add_processing_message(1, 'error', "Upload is missing or invalid.")
    end
    if @upload.file.url.blank?
      @process_log << add_processing_message(1, 'error', "File URL can't be blank.")
    end
    # return true or false depending on if errors were generated
    @process_log.empty?
  end  

  # Adds a message to the process log
  def add_processing_message(level, severity, text)
    
    # See if we are bumping the level up or down
    if @log_level < level
      while @log_level < level
        @process_log << "<ul>"
        @log_level += 1
      end
    elsif @log_level > level
      while @log_level > level
        @process_log << "</ul>"
        @log_level -= 1
      end
    end
    @log_level = level
    
    if level == 1
      @process_log << "<p class='text-#{severity}'>#{text}</p>" 
    elsif level == 2
      @process_log << "<li><p class='text-#{severity}'>#{text}</p></li>"
    end
    
  end

  protected
  def is_number?(val)
    Float(val) != nil rescue false
  end
  
  private
  def initialize(*args)
    @process_log = []
    @log_level = 1
  end
    
end
