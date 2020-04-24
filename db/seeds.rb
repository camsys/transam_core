#encoding: utf-8

# determine if we are using postgres or mysql
is_mysql = (ActiveRecord::Base.configurations[Rails.env]['adapter'].include? 'mysql2')
is_sqlite =  (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'sqlite3')
#------------------------------------------------------------------------------
#
# Lookup Tables
#
# These are the lookup tables for core TransAM
#
#------------------------------------------------------------------------------

puts "======= Processing TransAM CORE Lookup Tables  ======="

asset_event_types = [
  {:active => 1, :name => 'Condition',       :display_icon_name => "fa fa-star-half-o",       :description => 'Condition',       :class_name => 'ConditionUpdateEvent',      :job_name => 'AssetConditionUpdateJob'},
  {:active => 0, :name => 'Schedule replacement',       :display_icon_name => "fa fa-refresh",       :description => 'Scheduled replacement',       :class_name => 'ScheduleReplacementUpdateEvent',      :job_name => 'AssetScheduleReplacementUpdateJob'},
  {:active => 0, :name => 'Schedule rehabilitation',       :display_icon_name => "fa fa-wrench",       :description => 'Scheduled rehabilitation',       :class_name => 'ScheduleRehabilitationUpdateEvent',      :job_name => 'AssetScheduleRehabilitationUpdateJob'},
  {:active => 0, :name => 'Schedule disposition',       :display_icon_name => "fa fa-times-circle",       :description => 'Scheduled disposition',       :class_name => 'ScheduleDispositionUpdateEvent',      :job_name => 'AssetScheduleDispositionUpdateJob'},
  {:active => 1, :name => 'Service status',  :display_icon_name => "fa fa-bell",  :description => 'Service Status Update',  :class_name => 'ServiceStatusUpdateEvent',  :job_name => 'AssetServiceStatusUpdateJob'},
  {:active => 1, :name => 'Location',       :display_icon_name => "fa fa-map-marker",       :description => 'Location Update',       :class_name => 'LocationUpdateEvent',      :job_name => 'AssetLocationUpdateJob'},
  {:active => 1, :name => 'Rebuild / Rehabilitation',       :display_icon_name => "fa fa-wrench",       :description => 'Rehabilitation Update',       :class_name => 'RehabilitationUpdateEvent',      :job_name => 'AssetRehabilitationUpdateJob'},
  {:active => 1, :name => 'Record final disposition',     :display_icon_name => "fa fa-ban",      :description => 'Disposition Update',     :class_name => 'DispositionUpdateEvent',    :job_name => 'AssetDispositionUpdateJob'},
  {:active => 1, :name => 'Request early disposition',     :display_icon_name => "fa fa-ban",      :description => 'Early Disposition Request',     :class_name => 'EarlyDispositionRequestUpdateEvent',    :job_name => ''},
  {:active => 1, :name => "Maintenance history",          :display_icon_name => "fa fa-wrench",            :description => "Maintenance/Service Update",    :class_name => "MaintenanceUpdateEvent", :job_name => "AssetMaintenanceUpdateJob"}
]

condition_types = [
  {:active => 1, :name => 'Unknown',        :rating_ceiling => 0.99, :description => 'Asset condition is unknown.'},
  {:active => 1, :name => 'Poor',           :rating_ceiling => 1.94, :description => 'Asset is past its useful life and is in immediate need of repair or replacement. May have critically damaged components.'},
  {:active => 1, :name => 'Marginal',       :rating_ceiling => 2.94, :description => 'Asset is reaching or is just past the end of its useful life. Increasing number of defective or deteriorated components and experiencing increased maintenance needs.'},
  {:active => 1, :name => 'Adequate',       :rating_ceiling => 3.94, :description => 'Asset has reached its mid-life. Some moderately defective or deteriorated components.'},
  {:active => 1, :name => 'Good',           :rating_ceiling => 4.74, :description => 'Asset showing minimal signs of wear. Some defective or deteriorated components.'},
  {:active => 1, :name => 'Excellent',      :rating_ceiling => 5.00, :description => 'New asset. No visible defects.'}
]

disposition_types = [
  {:active => 1, :name => 'Public Sale',  :code => 'P', :description => 'Sold at public auction or other method.'},
  {:active => 1, :name => 'Transferred',  :code => 'T', :description => 'Transferred to another transportation provider.'},
  {:active => 1, :name => 'Reprovisioned',:code => 'R', :description => 'Reprovisioned as a spare or backup.'},
  {:active => 1, :name => 'Trade-In',     :code => 'I', :description => 'Trade in on purchase of new asset.'},
  {:active => 1, :name => 'Disposed',     :code => 'D', :description => 'Permanently disposed.'},
  {:active => 1, :name => 'Other',        :code => 'O', :description => 'Other disposition type.'}
]

service_status_types = [
  {:active => 1, :name => 'In Service',       :code => 'I', :description => 'Asset is in service.'},
  {:active => 1, :name => 'Out of Service',   :code => 'O', :description => 'Asset is temporarily out of service.'},
  {:active => 1, :name => 'Spare',            :code => 'S', :description => 'Asset has been reprovisioned as a spare.'},
  {:active => 0, :name => 'Disposed',         :code => 'D', :description => 'Asset has been permanently disposed.'},
  {:active => 0, :name => 'Unknown',          :code => 'U', :description => 'Asset service status is unknown.'}
]

rule_sets = [
    {name: 'Asset Replacement/Rehabilitation Policy', class_name: 'Policy', rule_set_aware: false, active: true}
]

cost_calculation_types = [
  {:active => 1, :name => 'Replacement Cost',             :class_name => "ReplacementCostCalculator",             :description => 'Calculate the replacement cost using the policy schedule only.'},
  {:active => 1, :name => 'Replacement Cost + Interest',  :class_name => "ReplacementCostPlusInterestCalculator", :description => 'Calculate the replacement cost using the policy schedule plus interest accrued between policy year and replacement year.'},
  {:active => 1, :name => 'Purchase Price + Interest',    :class_name => "PurchasePricePlusInterestCalculator",   :description => 'Calculate the replacement cost using the initial purchase price with accrued interest until the replacement year.'}
]

service_life_calculation_types = [
  {:active => 1, :name => 'Age Only',          :class_name => 'ServiceLifeAgeOnly',         :description => 'Calculate the replacement year based on the age of the asset.'},
  {:active => 1, :name => 'Condition Only',    :class_name => 'ServiceLifeConditionOnly',   :description => 'Calculate the replacement year based on the condition of the asset.'},
  {:active => 1, :name => 'Age and Condition', :class_name => 'ServiceLifeAgeAndCondition', :description => 'Calculate the replacement year based on the age of the asset and condition constraints being met.'},
  {:active => 1, :name => 'Age or Condition',  :class_name => 'ServiceLifeAgeOrCondition',  :description => 'Calculate the replacement year based on the age of the asset or condition constraints being met.'}
]

condition_estimation_types = [
  {:active => 1, :name => 'Straight Line',  :class_name => 'StraightLineEstimationCalculator',  :description => 'Asset condition is estimated using a straight-line approximation.'}
]

condition_rollup_calculation_types = [
    {name: 'Weighted Average', class_name: 'WeightedAverageConditionRollupCalculator', description: "Asset condition is calculated using a weighted average of its components' conditions."},
    {name: 'Median', class_name: 'MedianConditionRollupCalculator', description: "Asset condition is calculated using the median of its components' conditions."},
    {name: 'Custom Weighted', class_name: 'CustomWeightedConditionRollupCalculator', description: "Asset condition is calculated using a weighted average of conditions where the weight is custom set."}
]

file_content_types = [
  {:active => 1, :name => 'Inventory Updates',    :class_name => 'InventoryUpdatesFileHandler',  :builder_name => "InventoryUpdatesTemplateBuilder",    :description => 'Worksheet records updated condition, status, and mileage for existing inventory.'},
  {:active => 1, :name => 'Maintenance Updates',  :class_name => 'MaintenanceUpdatesFileHandler',:builder_name => "MaintenanceUpdatesTemplateBuilder",  :description => 'Worksheet records latest maintenance updates for assets'},
  {:active => 1, :name => 'Disposition Updates',  :class_name => 'DispositionUpdatesFileHandler',       :builder_name => "DispositionUpdatesTemplateBuilder", :description => 'Worksheet contains final disposition updates for existing inventory.'},
  {:active => 1, :name => 'New Inventory',    :class_name => 'NewInventoryFileHandler',   :builder_name => "NewInventoryTemplateBuilder",  :description => 'Worksheet records updated condition, status, and mileage for existing inventory.'}
]

manufacturer_models = [
    {name: 'Other', description: 'Other', active: true}
]

license_types = [
  {:active => 1, :name => 'Full',              :asset_manager => 1, :web_services => 1, :description => 'Access to application and web services.'},
  {:active => 1, :name => 'Application Only',  :asset_manager => 1, :web_services => 0, :description => 'Access to application only.'},
  {:active => 1, :name => 'Web Services Only', :asset_manager => 0, :web_services => 1, :description => 'Access to web services only.'}
]

priority_types = [
  {:active => 1, :is_default => 0, :name => 'Low',     :description => 'Lowest priority.'},
  {:active => 1, :is_default => 1, :name => 'Normal',  :description => 'Normal priority.'},
  {:active => 1, :is_default => 0, :name => 'High',    :description => 'Highest priority.'}
]

file_status_types = [
  {:active => 1, :name => 'Unprocessed',  :description => 'Unprocessed.'},
  {:active => 1, :name => 'In Progress',  :description => 'In Progress.'},
  {:active => 1, :name => 'Complete',     :description => 'Complete.'},
  {:active => 1, :name => 'Errored',      :description => 'Errored.'},
  {:active => 1, :name => 'Reverted',     :description => 'Changes have been undone and assets reverted to their previous state.'}
]

report_types = [
  {:active => 1, :name => 'Inventory Report',     :display_icon_name => "fa fa-bar-chart-o",  :description => 'Inventory Report.'},
  {:active => 1, :name => 'Capital Needs Report', :display_icon_name => "fa fa-usd",          :description => 'Capital Needs Report.'},
  {:active => 1, :name => 'Database Query',       :display_icon_name => "fa fa-database",     :description => 'Custom SQL Report.'},
  {:active => 1, :name => 'System Report',        :display_icon_name => "fa fa-cog",          :description => 'System Report.'}
]

issue_types = [
  {:active => 1, :name => 'Comment',      :description => 'Suggestion'},
  {:active => 1, :name => 'Enhancement',  :description => 'Enhancement.'},
  {:active => 1, :name => 'Bug',          :description => 'Bug'},
  {:active => 1, :name => 'Other',        :description => 'Other'}
]

issue_status_types = [
    {:active => 1, :name => 'Open',      :description => 'Open'},
    {:active => 1, :name => 'Resolved',  :description => 'Resolved'},
]

web_browser_types = [
  {:active => 1, :name => 'Microsoft IE 8',      :description => 'IE 8'},
  {:active => 1, :name => 'Microsoft IE 9',      :description => 'IE 9'},
  {:active => 1, :name => 'Microsoft IE 10',     :description => 'IE 10'},
  {:active => 1, :name => 'Microsoft IE 11',     :description => 'IE 11'},
  {:active => 1, :name => 'Microsoft Edge',      :description => 'Microsoft Edge'},
  {:active => 1, :name => 'Apple Safari',        :description => 'Safari'},
  {:active => 1, :name => 'Google Chrome',       :description => 'Chrome'},
  {:active => 1, :name => 'Mozilla Firefox',     :description => 'Firefox'},
  {:active => 1, :name => 'Other',               :description => 'Other'}
]

replacement_reason_types = [
  {:active => 1, :name => 'Reached policy EUL',       :description => 'The asset has reached the end of its useful life according to the policy.'},
  {:active => 1, :name => 'Damaged beyond repair',    :description => 'The asset has been damanaged and cannot be repaired.'},
  {:active => 1, :name => 'Substandard due to manufacture defects',      :description => 'The asset is a lemon and is being replaced to defer future maintenance/repair costs.'},
  {:active => 1, :name => 'Other',     :description => 'The asset is being replaced for other reasons.'}
]

roles = [
  {:privilege => false, :name => 'guest', :weight => 1, :show_in_user_mgmt => true},
  {:privilege => false, :name => 'user', :weight => 1, :show_in_user_mgmt => true},
  {:privilege => false, :name => 'manager', :weight => 7, :show_in_user_mgmt => true},
  {:privilege => true, :name => 'admin', :show_in_user_mgmt => true, :role_parent => 'user,manager'},
  {:privilege => true, :name => 'super_manager', :weight => 10, role_parent: 'manager', :show_in_user_mgmt => true},
  {:privilege => true, :name => 'technical_contact', :show_in_user_mgmt => true},
  {name: 'system_admin', role_parent: 'admin', weight: 1, privilege: true, show_in_user_mgmt: false},
  {:privilege => true, :name => 'asset_manager', :role_parent => 'manager', :show_in_user_mgmt => true, weight: 8}
]

manufacturers = [
    {filter: "Equipment", name: "Other (Describe)", code: "ZZZ", active: true}
]

notice_types = [
  {:active => 1,  :name => 'System Notice',   :description => 'System notices.', :display_icon => 'fa-warning', :display_class => 'text-danger'},
  {:active => 1,  :name => 'Informational Notice',  :description => 'Informational notices.', :display_icon => 'fa-exclamation', :display_class => 'text-info'}
]

message_templates = [
    {name: 'Task1', description: 'A message is sent to a user with a Task with a due date less than one week in the future.', delivery_rules: 'Sent when tasks are due less than or a week from now', subject: 'Incomplete Task Reminder', body: "<p>Task <strong>{subject}</strong> is incomplete and is due to be completed by <strong>{complete_by_date}</strong>.</p><p>You can view this task by clicking {link(here)}</p>", active: true, is_implemented: true},
    {name: 'Support1', description: "A message is sent to Admin if an issue is submitted through the 'Report an Issue' feature on a weekly basis.", delivery_rules: 'Sent x days/weeks/months (Activity defines) if new issues to admins', subject: "New Issues Report", body: "There are {new_issues.count} new issue(s) in the last {frequency}. You can view all issues {link(here)}.", active: true, is_implemented: true},
    {name: 'Support2', description: "A message is sent to Admin if the 'Delivery Rules' or 'Body' of a message is modified in any way.", delivery_rules: 'Sent when a template is added or changed', subject: "Message Template Changes", body: "The following message template {name} with the subject {subject} has changed. Please review for implementation changes.", active: true, is_implemented: true},
    {name: 'User1', description: 'A message is sent to new users upon account creation, prompting users to establish a password.', delivery_rules: 'Sent to new user',  subject: "A TransAM account has been created for you", body: "<h1>New User Confirmation</h1><p>A new user account has been created for you in TransAM</p><p>Your username: {email}</p><p>Please go to {new_user_password_url} and follow the instructions to reset your password.</p>", message_enabled: false, is_system_template: true, active: true, is_implemented: true},
    {name: 'User2', description: "A message is sent to existing users upon selecting 'Forgot My Password', prompting the user to reset their password.", delivery_rules: 'Sent on password reset',  subject:  "Reset password instructions", body: "<p>Hello {name}!</p><p>We have received a request to change your password. You can do this through the link below.</p><p>{link(Change my password)}</p><p>If you didn't request this, please ignore this email.</p><p>Your password won't change until you access the link above and create a new one.</p>", message_enabled: false, is_system_template: true, active: true, is_implemented: true},
    {name: 'User3', description: "A message is sent to any user with the 'Admin' privilege, when a user account has been locked, upon entering an incorrect password too many times.", delivery_rules: 'Sent to admin users',  subject:  'User account locked', body: "{locked_user.name} account was locked at {locked_user.locked_at}", active: true, is_implemented: true}
]

frequency_types = [
  {:active => 1, :name => 'second', :description => 'Second'},
  {:active => 1, :name => 'minute', :description => 'Minute'},
  {:active => 1, :name => 'hour', :description => 'Hour'},
  {:active => 1, :name => 'day', :description => 'Day'},
  {:active => 1, :name => 'week', :description => 'Week'},
  {:active => 1, :name => 'month', :description => 'Month'}
]

search_types = [
  {:active => 1, :name => 'Asset', :class_name => 'AssetMapSearcher'}
]

activities = [
    { name: 'Weekly Issues Report',
      description: 'Report giving an admin a list of all issues.',
      show_in_dashboard: false,
      system_activity: true,
      frequency_quantity: 1,
      frequency_type_id: 4,
      execution_time: 'Monday 00:01',
      job_name: 'IssuesReportJob',
      active: true },
    {:name => 'Task Reminders', :description => 'Send messages to users with task reminders for tasks due in a day or week.', :job_name => 'TaskReminderJob', :frequency_quantity => 1, :frequency_type_id => 3, :execution_time => '08:00', :show_in_dashboard => true, :active => true},
    {:name => 'Session Cleanup', :description => 'Session cleanup job every 15 mins.', :job_name => 'SessionCacheCleanupJob', :frequency_quantity => 15, :frequency_type_id => 2, :execution_time => '**:15', :show_in_dashboard => false, :active => true}
]

system_config_extensions = [
    {engine_name: 'core', class_name: Rails.application.config.asset_base_class_name, extension_name: 'TransamKeywordSearchable', active: true},
    {engine_name: 'core', class_name: 'User', extension_name: 'TransamKeywordSearchable', active: true},
    {engine_name: 'core', class_name: 'Vendor', extension_name: 'TransamKeywordSearchable', active: true}
]

system_config_extensions << {engine_name: 'core', class_name: 'AssetMapSearcher', extension_name: 'CoreAssetMapSearchable', active: true} if SystemConfig.transam_module_loaded? :spatial


lookup_tables = %w{asset_event_types condition_types disposition_types rule_sets cost_calculation_types license_types manufacturer_models priority_types
  file_content_types file_status_types report_types service_status_types
  service_life_calculation_types condition_estimation_types condition_rollup_calculation_types
  issue_status_types issue_types web_browser_types replacement_reason_types message_templates notice_types frequency_types search_types activities manufacturers system_config_extensions
  }

lookup_tables.each do |table_name|
  puts "  Loading #{table_name}"
  if is_mysql
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
  elsif is_sqlite
    ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
  else
    ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
  end
  data = eval(table_name)
  klass = table_name.classify.constantize
  data.each do |row|
    x = klass.new(row)
    x.save!
  end
end

table_name = 'roles'
puts "  Loading #{table_name}"
if is_mysql
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
elsif is_sqlite
  ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
else
  ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
end
data = eval(table_name)
klass = table_name.classify.constantize
data.each do |row|
  x = klass.new(row.except(:role_parent))
  x.save!
  (row[:role_parent] || '').split(',').each do |role|
    RolePrivilegeMapping.create!(privilege_id: x.id, role_id: Role.find_by(name: role).id)
  end
end

puts "======= Processing TransAM CORE Reports  ======="

reports = [
  {
    :active => 1,
    :belongs_to => 'report_type', :type => "System Report",
    :name => 'User Login Report',
    :class_name => "UserLoginReport",
    :view_name => "user_login_report_table",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'admin',
    :description => 'Displays a summary of user logins by organization.'
  },
  {
    :active => 1,
    :belongs_to => 'report_type', :type => "System Report",
    :name => 'Issues Report',
    :class_name => "CustomSqlReport",
    :view_name => "issues_report_table",
    :show_in_nav => 1,
    :show_in_dashboard => 0,
    :roles => 'admin',
    :description => 'Displays a list of reported user issues.',
    :custom_sql => 'SELECT d.short_name AS "ORGANIZATION", b.name AS "TYPE", a.created_at AS "DATE/TIME", a.comments AS "COMMENTS", e.name AS "BROWSER TYPE", c.first_name AS "FIRST NAME", c.last_name AS "LAST NAME", c.phone AS "PHONE", f.name AS "ISSUE_STATUS" , a.resolution_comments AS "RESOLUTION_COMMENTS", a.object_key AS "ISSUE ID" FROM issues a LEFT JOIN issue_types b ON a.issue_type_id=b.id LEFT JOIN users c ON a.created_by_id=c.id LEFT JOIN organizations d ON c.organization_id=d.id LEFT JOIN web_browser_types e ON a.web_browser_type_id=e.id LEFT JOIN issue_status_types f ON a.issue_status_type_id=f.id WHERE a.issue_status_type_id != 2 ORDER BY a.created_at'
  }
]

table_name = 'reports'
puts "  Loading #{table_name}"
if is_mysql
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
elsif is_sqlite
  ActiveRecord::Base.connection.execute("DELETE FROM #{table_name};")
else
  ActiveRecord::Base.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY;")
end
data = eval(table_name)
data.each do |row|
  x = Report.new(row.except(:belongs_to, :type))
  x.report_type = ReportType.where(:name => row[:type]).first
  x.save!
end

asset_subsystems = [
]
asset_subsystems.each do |s|
  asset_type = AssetType.find_by(name: [:asset_type]) # subsystems can be optionally scoped to only a single asset type
  subsystem = AssetSubsystem.create(s)
  subsystem.asset_type = asset_type
end


### Load any special SQL scripts here
puts "======= Loading TransAM Core SQL Scripts  ======="

unless SystemConfig.transam_module_loaded? :transit
  puts "  Loading asset_event_views"
  File.read(File.join(File.dirname(__FILE__), 'most_recent_asset_event_views.sql'))
    .split(';').map(&:strip).each do |statement|

    ActiveRecord::Base.connection.execute(statement)
  end
end

# asset query seeds
require_relative File.join("seeds", 'asset_query_seeds')
