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
  {:active => 1, :name => 'Rehabilitation',       :display_icon_name => "fa fa-wrench",       :description => 'Rehabilitation Update',       :class_name => 'RehabilitationUpdateEvent',      :job_name => 'AssetRehabilitationUpdateJob'},
  {:active => 1, :name => 'Record final disposition',     :display_icon_name => "fa fa-ban",      :description => 'Disposition Update',     :class_name => 'DispositionUpdateEvent',    :job_name => 'AssetDispositionUpdateJob'},
  {:active => 1, :name => 'Request early disposition',     :display_icon_name => "fa fa-ban",      :description => 'Early Disposition Request',     :class_name => 'EarlyDispositionRequestUpdateEvent',    :job_name => ''},
  {:active => 1, :name => "Maintenance history",          :display_icon_name => "fa fa-wrench",            :description => "Maintenance/Service Update",    :class_name => "MaintenanceUpdateEvent", :job_name => "AssetMaintenanceUpdateJob"}
]

condition_types = [
  {:active => 1, :name => 'Unknown',        :rating => 0.0, :description => 'Asset condition is unknown.'},
  {:active => 1, :name => 'Poor',           :rating => 1.0, :description => 'Asset is past its useful life and is in immediate need of repair or replacement. May have critically damaged components.'},
  {:active => 1, :name => 'Marginal',       :rating => 2.0, :description => 'Asset is reaching or is just past the end of its useful life. Increasing number of defective or deteriorated components and experiencing increased maintenance needs.'},
  {:active => 1, :name => 'Adequate',       :rating => 3.0, :description => 'Asset has reached its mid-life. Some moderately defective or deteriorated components.'},
  {:active => 1, :name => 'Good',           :rating => 4.0, :description => 'Asset showing minimal signs of wear. Some defective or deteriorated components.'},
  {:active => 1, :name => 'New/Excellent',  :rating => 5.0, :description => 'New asset. No visible defects.'}
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
  {:active => 0, :name => 'Disposed',         :code => 'D', :description => 'Asset has been permanently disposed.'}
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
  {:privilege => false, :name => 'guest', :weight => 1},
  {:privilege => false, :name => 'user', :weight => 1},
  {:privilege => false, :name => 'manager', :weight => 7},
  {:privilege => true, :name => 'admin'},
  {:privilege => true, :name => 'super_manager', :weight => 10},
  {:privilege => true, :name => 'technical_contact'}

]

notice_types = [
  {:active => 1,  :name => 'System Notice',   :description => 'System notices.', :display_icon => 'fa-warning', :display_class => 'text-danger'},
  {:active => 1,  :name => 'Informational Notice',  :description => 'Informational notices.', :display_icon => 'fa-exclamation', :display_class => 'text-info'}
]

frequency_types = [
  {:active => 1, :name => 'second', :description => 'Second'},
  {:active => 1, :name => 'minute', :description => 'Minute'},
  {:active => 1, :name => 'day', :description => 'Day'},
  {:active => 1, :name => 'week', :description => 'Week'},
  {:active => 1, :name => 'month', :description => 'Month'}
]

search_types = [
  {:active => 1, :name => 'Asset', :class_name => 'AssetSearcher'}
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
      active: true }
]


lookup_tables = %w{asset_event_types condition_types disposition_types cost_calculation_types license_types priority_types
  file_content_types file_status_types report_types service_status_types
  service_life_calculation_types condition_estimation_types condition_rollup_calculation_types
  issue_status_types issue_types web_browser_types replacement_reason_types roles notice_types frequency_types search_types activities
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

puts "======= Processing TransAM CORE Reports  ======="

reports = [
  {
    :active => 1,
    :belongs_to => 'report_type', :type => "System Report",
    :name => 'User Login Report',
    :class_name => "UserLoginReport",
    :view_name => "user_login_report_table",
    :show_in_nav => 0,
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
