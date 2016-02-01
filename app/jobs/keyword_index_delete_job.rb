#------------------------------------------------------------------------------
#
# KeywordIndexDeleteJob
#
# Deletes the keyword index for an object
#
#------------------------------------------------------------------------------
class KeywordIndexDeleteJob < Job

  attr_accessor :object_key
  attr_accessor :class_name

  def run
    klass = class_name.constantize
    if klass
      # If we got the class then call the update method
      klass.remove_from_index object_key    
    else
      raise RuntimeError, "Can't instantiate class #{class_name}"
    end
  end

  def prepare
    Rails.logger.info "Executing KeywordIndexDeleteJob at #{Time.now.to_s} for Keyword Index #{object_key}"
  end

  def check
    raise ArgumentError, "class_name can't be blank " if class_name.blank?
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end

  def initialize(class_name, object_key)
    super
    self.class_name = class_name
    self.object_key = object_key
  end

end
