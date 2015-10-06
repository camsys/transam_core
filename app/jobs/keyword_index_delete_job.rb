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
      klass_instance = klass.find_by(:object_key => object_key)
      if klass_instance
        # If we got the class then call the update method
        klass_instance.remove_from_index
      else
        raise RuntimeError, "Can't find #{class_name} with object_key #{object_key}"
      end
    else
      raise RuntimeError, "Can't instantiate class #{class_name}"
    end
  end

  def prepare
    Rails.logger.debug "Executing KeywordIndexUpdateJob at #{Time.now.to_s} for Upload #{object_key}"
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
