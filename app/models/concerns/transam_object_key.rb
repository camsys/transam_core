#------------------------------------------------------------------------------
#
# TransamObjectKey
#
# Adds a unique object key to a model
#
#------------------------------------------------------------------------------
module TransamObjectKey
  
  extend ActiveSupport::Concern

  included do
    # Always generate a unique object key before saving to the database
    before_validation(:on => :create) do
      generate_object_key(:object_key)
    end

    after_validation :check_for_duplicate_object_keys

    validates :object_key, :presence => true, :length => { is: 12 }
    validates :object_key, :uniqueness => true, unless: :skip_uniqueness?
  end

  # Only generate an objecrt key if one is not set. This allows objects to be
  # replaced but maintain the same object key
  def generate_object_key(column)
    if self[column].blank?
      begin
        # Note Time.now.to_f converts to seconds since Epoch, which is correct
        self[column] = (Time.now.to_f * 10000000).to_i.to_s(24).upcase
      end #while self.exists?(column => self[column])
    end
  end
  # Use the object key as the restful parameter
  def to_param
    object_key
  end

  protected

  def skip_uniqueness?
    false
  end

  def check_for_duplicate_object_keys
    if self.errors.details[:object_key].map{|x| x[:error]}.include? :taken

      puts "Sending metrics for duplicate object key validation error"
      # send metrics with object_keys that are duplicated
      PutMetricDataService.new.put_metric("#{self.class}HasDuplicates", 'Count', 1, [
          {
              'Name' => 'Object Key',
              'Value' => self.object_key
          }
      ])

      # send metric to show that there are duplicates - used for alarms
      PutMetricDataService.new.put_metric('DuplicateObjectKeyCount', 'Count', 1, [
          {
              'Name' => 'Class Name',
              'Value' => self.class.to_s
          }
      ])
    end
  end
end
