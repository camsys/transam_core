class Message < ActiveRecord::Base
  
  # Associations
  belongs_to :organization
  belongs_to :user
  belongs_to :to_user, :class_name => 'User', :foreign_key => "to_user_id"
  belongs_to :priority_type
  belongs_to :thread, :class_name => "Message"

  has_many   :responses, :class_name => "Message", :foreign_key => "thread_message_id"
  
  #attr_accessible :organization_id, :user_id, :to_user_id, :priority_type_id, :subject, :body, :created_at

  validates :organization_id, :presence => true
  validates :user_id, :presence => true
  validates :priority_type_id, :presence => true
  validates :subject, :presence => true
  validates :body, :presence => true
   
   default_scope { order('created_at DESC') }
      
   # Recursively determine how many total responses there are to this thread
   def response_count
     sum = 0
     responses.each do |r|
       sum += 1
       sum += r.response_count
     end
     return sum
   end
   
end
