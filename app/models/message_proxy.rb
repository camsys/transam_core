# 
#     A user may want to send a message to more than one person
#   The message proxy holds a template message, as well as the 
#   additional information required to send it to a number of
#   people (for instance, sending by role or sending to all users at
#   an organization)
# 
class MessageProxy < Proxy
  extend ActiveModel::Naming

  attr_accessor :group_role, :group_agency, :available_agencies

  # @message is a PROTOTYPE holding everything except to_user_id
  attr_reader :message, :messages_sent

  validates :priority_type_id,  :presence => true
  validates :subject,           :presence => true
  validates :body,              :presence => true
  validate  :at_least_one_target_user


  # A list of users (>=1) that will receive messages from the given parameters
  def target_users 
    total_users = 0
    if self.to_user_id.nil? # "No User Selected" -> use agency and role selectors
      if @group_agency.eql?("all")
        agency_basis = @available_agencies
      else
        agency_basis = @group_agency
      end
      total_users = User.where(organization_id: agency_basis)
      # Filter down to_users from form params
      total_users = total_users.with_role(Role.find(@group_role).name) unless @group_role.blank?
    else # user has selected a specific user
      total_users = User.where(id: self.to_user_id)
    end

    total_users -[@message.user]
  end

  def save
    if valid?
      persist
      true
    else
      false
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @message.respond_to? method_name || super
  end

  private

  def initialize(attrs = {})
    # Messages will be sent to one-or-more users based on form parameters
    @message = Message.new(attrs)
    @messages_sent = 0
    super
  end
  

  #############################################################################
  # 
  #  Validation Methods
  # 
  #############################################################################

  def at_least_one_target_user
    @errors.add(:base, "Messages must have at least one recipient") unless target_users.count > 0
  end


  #############################################################################
  # 
  #  Plumbing
  # 
  #############################################################################

  def persist
    target_users.each do |u|
      message_to_send = @message.dup
      message_to_send.to_user = u
      if message_to_send.save
        @messages_sent += 1
      end
    end
  end

  # Wrap the @message and Message, allowing us to delegate all methods
  def method_missing(method_sym, *arguments, &block)
    # binding.pry
    @message.send(method_sym, *arguments, &block)
  end
end