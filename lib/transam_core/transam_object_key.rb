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

  def generate_object_key(column)
    begin
      self[column] = (Time.now.to_f * 10000000).to_i.to_s(24).upcase
    end #while self.exists?(column => self[column])
  end
  
  def to_param
    object_key
  end

end
