#------------------------------------------------------------------------------
#
# NewUserService
#
# Contains business logic associated with creating new users
#
#------------------------------------------------------------------------------

class NewUserService

  def build(form_params)

    user = User.new(form_params)
    # Set up a default password for them
    user.password = SecureRandom.base64(8)
    # Activate the account immediately
    user.active = true
    # Override opt-in for email notifications
    user.notify_via_email = true

    return user
  end

  # Steps to take if the user was valid
  def post_process(user)

    # add user's filters
    f = UserOrganizationFilter.new({:active => 1, :name => "#{user.name}'s organizations", :description => "#{user.name}'s organizations", :sort_order => 1})
    f.users = [user]
    f.creator = User.find_by(first_name: 'system')
    f.query_string = Organization.active.joins(:users).where('users_organizations.user_id = ?', user.id).to_sql
    f.save!

    user.user_organization_filter = f

    UserOrganizationFilter.where('resource_type IS NOT NULL').each do |filter|
      if user.respond_to? filter.resource_type.downcase.pluralize #check has many associations
        if user.try(filter.resource_type.downcase.pluralize).include? filter.resource
          user.user_organization_filters << filter
        end
      elsif user.respond_to? filter.resource_type.downcase # check single association
        if user.try(filter.resource_type.downcase) == filter.resource
          user.user_organization_filters << filter
        end
      end
    end

    user.save

    UserMailer.send_email_on_user_creation(user).deliver
  end
end
