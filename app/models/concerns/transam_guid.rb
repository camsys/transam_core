#------------------------------------------------------------------------------
#
# TransamGuid
#
# Adds a unique GUID to a model
#
#------------------------------------------------------------------------------
module TransamGuid
  
  extend ActiveSupport::Concern

  included do
    # Always generate a unique GUID before saving to the database
    before_validation(:on => :create) do
      generate_guid(:guid)
    end

    validates :guid, :presence => true, :uniqueness => true
  end

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  module ClassMethods

  end

  # Only generate an GUID if one is not set. This allows objects to be
  # replaced but maintain the same GUID
  def generate_guid(column)
    if self[column].blank?
      begin
        self[column] = SecureRandom.uuid
      end
    end
  end

  protected

end
