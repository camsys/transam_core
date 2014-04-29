#------------------------------------------------------------------------------
#
# Comment
#
# A comment that has been associated with another class such as a Task etc. This is a 
# polymorphic class that can store comments against any class that includes a
# commentable association
#
# To use this class as an association with another class include the following line into
# the model
#
# has_many    :comments,  :as => :commentable
#
#------------------------------------------------------------------------------
class Comment < ActiveRecord::Base

  # Include the unique key mixin
  include UniqueKey

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the asset key as the restful parameter. All URLS will be of the form
  # /asset_event/{object_key}/...
  def to_param
    object_key
  end
      
  # Callbacks
  after_initialize  :set_defaults

  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
            
  # Associations
  belongs_to :commentable,  :polymorphic => true
  
  # Each comment was created by a user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by_id"
  
  validates :comment,             :presence => true
  validates :created_by_id,       :presence => true

  # List of hash parameters allowed by the controller
  FORM_PARAMS = [
    :object_key,
    :comment,
    :commentable_id,
    :commentable_type,
    :created_by_id
  ]
  
  #------------------------------------------------------------------------------
  #
  # Class Methods
  #
  #------------------------------------------------------------------------------
    
  def self.allowable_params
    FORM_PARAMS
  end
    
  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  # Set resonable defaults for a new asset event
  def set_defaults

  end    
    
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
  
end
