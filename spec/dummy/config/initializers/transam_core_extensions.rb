# Base class name is to determine base asset class. Seed class is used to determine seed that gets typed (or very specific) asset class.
Rails.application.config.asset_base_class_name = 'Asset'

Rails.application.config.active_job.queue_adapter = :delayed_job

# fiscal years
# some controllers might have a special formatter instead of the default one to use the FY string
Rails.application.config.special_fiscal_year_formatters = {"TamPolicy" => 'end_year'}
# This is where an application can delay the fiscal year rollover
# up to the end of the calendar year
Rails.application.config.delay_fiscal_year_rollover = false

Rails.application.config.dashboard_widgets = [
    ['assets_widget', 1],
    ['task_queues', 1],
    ['queues', 1],
    ['cpt_widget', 2],
    ['funding_widget', 2],
    ['notices_widget', 3],
    ['message_queues', 3],
    ['audit_widget', 3]
]

Rails.application.config.new_user_service = "NewUserService"
Rails.application.config.user_role_service = "UserRoleService"
Rails.application.config.policy_analyzer = "PolicyAnalyzer"
