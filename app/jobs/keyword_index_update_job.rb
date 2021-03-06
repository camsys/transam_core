#------------------------------------------------------------------------------
#
# KeywordIndexUpdateJob
#
# Updates the keyword index for an object
#
#------------------------------------------------------------------------------
class KeywordIndexUpdateJob < Job

  attr_accessor :object_key
  attr_accessor :class_name

  def run
    begin
      klass = class_name.constantize
    rescue
      raise RuntimeError, "Can't instantiate class #{class_name}"
    end
    if klass
      klass_instance = klass.find_by(:object_key => object_key)
      if klass_instance
        # If we got the class then call the update method
        klass_instance.write_to_index
      else
        Rails.logger.info "Can't find #{class_name} with object_key #{object_key}"
      end
    end

  end

  def prepare
    Rails.logger.info "Executing KeywordIndexUpdateJob at #{Time.now.to_s} for Keyword Index #{object_key}"
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
