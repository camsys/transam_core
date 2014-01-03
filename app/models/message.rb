class Message < ActiveRecord::Base
  
  # Include the unique key mixin
  include UniqueKey

  #------------------------------------------------------------------------------
  # Overrides
  #------------------------------------------------------------------------------
  
  #require rails to use the key as the restful parameter. All URLS will be of the form
  # /message/{object_key}/...
  def to_param
    object_key
  end
  
  #------------------------------------------------------------------------------
  # Callbacks
  #------------------------------------------------------------------------------
  after_initialize  :set_defaults

  # Always generate a unique asset key before saving to the database
  before_validation(:on => :create) do
    generate_unique_key(:object_key)
  end
  
  # Associations
  belongs_to :organization
  belongs_to :user
  belongs_to :to_user, :class_name => 'User', :foreign_key => "to_user_id"
  belongs_to :priority_type
  belongs_to :thread, :class_name => "Message", :foreign_key => "message_id"

  has_many   :responses, :class_name => "Message", :foreign_key => "thread_message_id"
  
  # Validations on core attributes
  validates :object_key,        :presence => true, :uniqueness => true
  validates :organization_id,   :presence => true
  validates :user_id,           :presence => true
  validates :priority_type_id,  :presence => true
  validates :subject,           :presence => true
  validates :body,              :presence => true
   
  default_scope { order('created_at DESC') }
      
  # List of allowable form param hash keys  
  FORM_PARAMS = [
    :object_key,
    :organization_id,
    :user_id,
    :to_user_id,
    :thread_message_id,
    :priority_type_id,
    :subject,
    :body
  ]
  
  def self.allowable_params
    FORM_PARAMS
  end
      
  # Recursively determine how many total responses there are to this thread
  def response_count
    sum = 0
    responses.each do |r|
      sum += 1
      sum += r.response_count
    end
    return sum
  end
   
  # Set resonable defaults for a new message
  def set_defaults
  end    
   
end
