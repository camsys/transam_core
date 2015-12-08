
# Defines services to use
Rails.application.config.new_user_service = "NewUserService"
Rails.application.config.user_role_service  = "UserRoleService"
Rails.application.config.policy_analyzer = "PolicyAnalyzer"

Rails.configuration.to_prepare do
  # Inject the search behavior into the searchable classes
  Equipment.class_eval do
    include TransamKeywordSearchable
  end
end
