#------------------------------------------------------------------------------
#
# SendMessageAsEmailJob
#
# Sends a message as an email
#
#------------------------------------------------------------------------------
class SendMessageAsEmailJob < Job
  
  attr_accessor :object_key
  
  def run    
    message = Message.find_by_object_key(object_key)
    if message
      UserMailer.email_message(message).deliver      
    else
      raise RuntimeError, "Can't find Message with object_key #{object_key}"
    end
  end

  def prepare
    Rails.logger.info "Executing SendMessageAsEmailJob at #{Time.now.to_s} for Message #{object_key}"    
  end
  
  def check    
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end
  
  def initialize(object_key)
    super
    self.object_key = object_key
  end

end