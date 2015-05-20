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

    validates :object_key, :presence => true, :uniqueness => true, :length => { is: 12 }
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

end
