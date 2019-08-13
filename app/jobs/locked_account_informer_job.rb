#------------------------------------------------------------------------------
#
# LockedAccountInformerJob
#
# Searches for acccounts that have been locked and sends an email to the
# administrators
#
#------------------------------------------------------------------------------
class LockedAccountInformerJob < Job
    
  attr_accessor :object_key
      
  def run

    locked_user = User.find_by_object_key(object_key)
    if locked_user
      # Get the system user
      sys_user = get_system_user
      
      # Get the admin users
      admins = User.with_role :admin

      message_template = MessageTemplate.find_by(name: 'User3', active: true)

      if message_template
        message_body = MessageTemplateMessageGenerator.new.generate(message_template, [locked_user.name, locked_user.locked_at])
        # Send a message to the admins for this user organization
        admins.each do |admin|
          msg = Message.new
          msg.organization  = admin.organization
          msg.user          = sys_user
          msg.to_user       = admin
          msg.subject       = message_template.subject
          msg.body          = message_body
          msg.priority_type = message_template.priority_type
          msg.message_template = message_template
          msg.save
        end
      end

    else
      raise RuntimeError, "Can't find User with object_key #{object_key}"
    end

  end

  def prepare
    Rails.logger.info "Executing LockedAccountInformerJob at #{Time.now.to_s} for User #{object_key}"    
  end
  
  def check    
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end
  
  def initialize(object_key)
    super
    self.object_key = object_key
  end

end