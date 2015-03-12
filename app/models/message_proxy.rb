#-------------------------------------------------------------------------------
# MessageProxy
#
# Proxy class for gathering new message data
#
#-------------------------------------------------------------------------------
class MessageProxy < Proxy

  #-----------------------------------------------------------------------------
  # Attributes
  #-----------------------------------------------------------------------------
  attr_accessor :priority_type_id
  attr_accessor :to_user_ids
  attr_accessor :group_roles
  attr_accessor :group_agencys
  attr_accessor :available_agencies
  attr_accessor :subject
  attr_accessor :body
  attr_accessor :send_to_group

  #-----------------------------------------------------------------------------
  # Validations
  #-----------------------------------------------------------------------------
  validates :priority_type_id,  :presence => true
  validates :subject,           :presence => true
  validates :body,              :presence => true

  validate  :at_least_one_target_user

  #-----------------------------------------------------------------------------
  # Constants
  #-----------------------------------------------------------------------------

  # List of allowable form param hash keys
  FORM_PARAMS = [
    :priority_type_id,
    :subject,
    :body,
    :send_to_group,
    :to_user_ids => [],
    :group_roles => [],
    :group_agencys => []
  ]

  #-----------------------------------------------------------------------------
  #
  # Class Methods
  #
  #-----------------------------------------------------------------------------

  def self.allowable_params
    FORM_PARAMS
  end

  #-----------------------------------------------------------------------------
  #
  # Instance Methods
  #
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #-----------------------------------------------------------------------------
  protected

  def at_least_one_target_user
    if send_to_group == '0'
      user_ids = []
      to_user_ids.each {|x| user_ids << x unless x.blank?}
      @errors.add(:to_user_ids, "At least one user must be selected") if user_ids.empty?
    else
      group_ids = []
      group_roles.each {|x| group_ids << x unless x.blank?}
      group_agencys.each {|x| group_ids << x unless x.blank?}
      @errors.add(:base, "At least one organization or user role must be selected") if group_ids.empty?
    end
  end

  def initialize(attrs = {})
    super
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
    self.send_to_group ||= '0'
    self.to_user_ids ||= []
    self.group_roles ||= []
    self.group_agencys ||= []
  end

end
