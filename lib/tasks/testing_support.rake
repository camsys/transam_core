namespace :transam_core do
  desc "Ensure that test users exist"
  task ensure_test_users: :environment do
    pwd = Rails.application.class.parent.to_s.upcase+'-'+Rails.application.config.version.split('-')[0]
    org = Organization.first
    (1..5).each do |n|
      email = 
      last = "Admin#{n}"

      user = User.find_or_create_by(email: "transam_admin#{n}@camsys.com", first_name: 'TransAM', last_name: "Admin#{n}",
                                    phone: '781-539-6700', notify_via_email: true, organization: org)
      user.password = pwd unless user.valid_password?(pwd)

      # Only needed if client uses cpt
      if user.respond_to?(:user_activity_line_item_filter)
        sys_user_id = TransamHelper.system_user.id

        user.user_activity_line_item_filters = UserActivityLineItemFilter.where(created_by_user_id: sys_user_id)
        user.user_activity_line_item_filter = UserActivityLineItemFilter.find_by(name: 'All ALIs', created_by_user_id: sys_user_id)
      end
      
      user.save!
      user.organizations << org
      user.viewable_organizations = Organization.all
      user.update_user_organization_filters

      ['user', 'super_manager', 'admin'].each {|role| user.add_role role}
    end
  end
end
