#------------------------------------------------------------------------------
#
# UploadProcessorJob
#
# Processes a spreadsheet uploaded by a user. The spreadsheet can contain new
# inventory or updates to existing inventory
#
#------------------------------------------------------------------------------
class UploadProcessorJob < Job

  attr_accessor :object_key

  def run
    upload = Upload.find_by_object_key(object_key)
    if upload
      # Get the handler for the upload. This is defined via the file_content_type class
      begin
        klass = upload.file_content_type.class_name.constantize.new(upload)
        if klass.can_process?
          klass.execute
        end
      rescue Exception => e
        Rails.logger.error e.message
        raise RuntimeError.new "Processing failed for Upload #{object_key}"
      end
    else
      raise RuntimeError, "Can't find upload with object_key #{object_key}"
    end
  end

  def prepare
    Rails.logger.debug "Executing UploadProcessorJob at #{Time.now.to_s} for Upload #{object_key}"
  end

  def check
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end

  def initialize(object_key)
    super
    self.object_key = object_key
  end

end
