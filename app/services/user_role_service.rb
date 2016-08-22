#-------------------------------------------------------------------------------
#
# UserRoleService
#
# Contains business logic associated with managing user roles after an update
# or create event for a new user
#
#-------------------------------------------------------------------------------
class UserRoleService

  #-----------------------------------------------------------------------------
  # Returns the set of roles a user can assign to another user
  #-----------------------------------------------------------------------------
  def assignable_roles user
    Role.roles.where('weight <= ?', user.primary_role.weight)
  end
  #-----------------------------------------------------------------------------
  # Returns the set of roles a user can assign to another user. Only admins can
  # assign an admin privilege
  #-----------------------------------------------------------------------------
  def assignable_privileges user
    if user.has_role? :admin
      Role.privileges
    else
      Role.privileges.where('name <> ?', "admin")
    end
  end
  #-----------------------------------------------------------------------------
  # Override this method to invoke business logic for managing roles. Params
  # are:
  #   user      - the user being updated
  #   manager   - the user doing the updating (usually current_user)
  #   role_id   - the role_id that the user should have
  #   privilege_ids - an array of privilege ids that the user should have
  #-----------------------------------------------------------------------------
  def set_roles_and_privileges(user, manager, role_id, privilege_ids)

    Rails.logger.debug "Assign roles and privileges: user = #{user}, manager = #{manager}, role_id = #{role_id}, privilege_ids = #{privilege_ids}"
    return if user.blank?

    # Check all the roles and privileges and revoke/assign as needed
    Role.all.each do |role|
      Rails.logger.debug "Checking role #{role}, id = #{role.id}"
      if role_id == role.id.to_s
        # Its the role they are assigned
        assign_role user, role, manager

      elsif privilege_ids.include? role.id.to_s
        # Its a privilege they should be assigned
        assign_role user, role, manager

      else
        # otherwise revoke it if it exists
        revoke_role user, role, manager
      end
    end

    # Make sure the user has the user role and assign it if they dont (except for guests)
    if (!(user.has_role? :guest) && !(user.has_role? :user))
      assign_role user, Role.find_by(:name => 'user'), manager
    end
  end

  #-----------------------------------------------------------------------------
  # Override this method to invoke any business logic for post processing after
  # a user has been created and saved. For example, sending emails, configuring
  # accounts, etc.
  #-----------------------------------------------------------------------------
  def post_process(user)
    # No actions
  end

  #-----------------------------------------------------------------------------
  # Protected methods
  #-----------------------------------------------------------------------------
  protected

  #-----------------------------------------------------------------------------
  # Assigns a single role or privilege to a user
  #-----------------------------------------------------------------------------
  def assign_role user, role, manager

    Rails.logger.debug "Assigning role #{role} for user #{user}"

    begin
      users_role = UsersRole.find_or_create_by(:user => user, :role => role) do |r|
        r.granted_by_user = manager
        r.granted_on_date = Date.today
        r.active = true
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
  #-----------------------------------------------------------------------------
  # Revokes a single role or privilege from a user
  #-----------------------------------------------------------------------------
  def revoke_role user, role, manager
    # must search by WHERE because no primary key ID for .destroy. Use .delete_all
    users_role = UsersRole.where(:user => user, :role => role)
    if users_role.present?
      Rails.logger.debug "Revoking role #{role} for user #{user}. #{users_role.inspect}"
      users_role.delete_all
      #user.remove_role role.name
      # users_role.active = false
      # users_role.revoked_by_user = manager
      # users_role.revoked_on_date = Date.today
      # users_role.save
    end

  end

end
