class TransamAssetRecord < ApplicationRecord
  self.abstract_class = true

  # Returns an array of asset event classes that this asset can process
  def self.event_classes
    a = []
    # Use reflection to return the list of has many associatiopns and filter those which are
    # events
    self.reflect_on_all_associations(:has_many).each do |assoc|
      a << assoc.klass if assoc.class_name.end_with? 'UpdateEvent'
    end
    a
  end

  def to_param
    object_key
  end
end