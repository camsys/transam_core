#------------------------------------------------------------------------------
#
# LockedAccountInformerJob
#
# Searches for acccounts that have been locked and sends an email to the
# administrators
#
#------------------------------------------------------------------------------
class MessageTemplateInformerJob < Job
    
  attr_accessor :object_key
      
  def run

    templated_changed = MessageTemplate.find_by_object_key(object_key)
    if templated_changed
      # Get the system user
      sys_user = get_system_user
      
      # Get the admin users
      admins = User.with_role :client_admin

      message_template = MessageTemplate.find_by(name: 'Support2')
      message_body = MessageTemplateMessageGenerator.new.generate(message_template, [templated_changed.name, templated_changed.subject])

      # Send a message to the admins for this user organization
      admins.each do |admin|
        msg = Message.new
        msg.organization  = admin.organization
        msg.user          = sys_user
        msg.to_user       = admin
        msg.subject       = message_template.subject
        msg.body          = message_body
        msg.priority_type = message_template.priority_type
        msg.save
      end

    else
      raise RuntimeError, "Can't find Message Template with object_key #{object_key}"
    end

  end

  def prepare
    Rails.logger.info "Executing MessageTemplateInformerJob at #{Time.now.to_s} for Template #{object_key}"
  end
  
  def check    
    raise ArgumentError, "object_key can't be blank " if object_key.blank?
  end
  
  def initialize(object_key)
    super
    self.object_key = object_key
  end

end