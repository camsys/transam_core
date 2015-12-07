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

      # Get the priority
      priority_type = PriorityType.find_by_name('Normal')

      # Send a message to the admins for this user organization
      admins.each do |admin|
        msg = Message.new
        msg.organization  = admin.organization
        msg.user          = sys_user
        msg.to_user       = admin
        msg.subject       = 'User account locked'
        msg.body          = "#{locked_user.name} account was locked at #{locked_user.locked_at}"
        msg.priority_type = priority_type
        msg.save
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