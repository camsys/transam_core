#encoding: utf-8

# determine if we are using postgres or mysql
is_mysql = (ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'mysql2')

#------------------------------------------------------------------------------
#
# Lookup Tables
#
# These are the lookup tables for core TransAM
#
#------------------------------------------------------------------------------

condition_types = [
  {:active => 1, :name => 'Unknown',        :rating => 0.0, :description => 'Asset condition is unknown.'},
  {:active => 1, :name => 'Poor',           :rating => 1.0, :description => 'Asset is past its useful life and is in immediate need of repair or replacement. May have critically damaged components.'},
  {:active => 1, :name => 'Marginal',       :rating => 2.0, :description => 'Asset is reaching or is just past the end of its useful life. Increasing number of defective or deteriorated components and experiencing increased maintenance needs.'},
  {:active => 1, :name => 'Adequate',       :rating => 3.0, :description => 'Asset has reached its mid-life. Some moderately defective or deteriorated components.'},
  {:active => 1, :name => 'Good',           :rating => 4.0, :description => 'Asset showing minimal signs of wear. Some defective or deteriorated components.'},
  {:active => 1, :name => 'New/Excellent',  :rating => 5.0, :description => 'New asset. No visible defects.'}
]

disposition_types = [
  {:active => 1, :name => 'Unknown',      :code => 'U', :description => 'Asset disposition is unknown.'},
  {:active => 1, :name => 'Public Sale',  :code => 'P', :description => 'Sold at public auction or other method.'},
  {:active => 1, :name => 'Transferred',  :code => 'T', :description => 'Transferred to another transportation provider.'},
  {:active => 1, :name => 'Reprovisioned',:code => 'R', :description => 'Reprovisioned as a spare or backup.'},
  {:active => 1, :name => 'Trade-In',     :code => 'I', :description => 'Trade in on purchase of new asset.'}
]

service_status_types = [
  {:active => 1, :name => 'Unknown',          :code => 'U', :description => 'Asset service status is unknown.'},
  {:active => 1, :name => 'In Service',       :code => 'I', :description => 'Asset is in service.'},
  {:active => 1, :name => 'Out of Service',   :code => 'O', :description => 'Asset is temporarily out of service.'},
  {:active => 1, :name => 'Spare',            :code => 'S', :description => 'Asset has been reprovisioned as a spare.'},
  {:active => 1, :name => 'Disposed',         :code => 'D', :description => 'Asset has been permanently disposed.'}
]

cost_calculation_types = [
  {:active => 1, :name => 'Replacement Cost',             :class_name => "ReplacementCostCalculator",             :description => 'Calculate the replacement cost using the policy schedule only.'},
  {:active => 1, :name => 'Replacement Cost + Interest',  :class_name => "ReplacementCostPlusInterestCalculator", :description => 'Calculate the replacement cost using the policy schedule plus interest accrued between policy year and replacement year.'},
  {:active => 1, :name => 'Purchase Price + Interest',    :class_name => "PurchasePricePlusInterestCalculator",   :description => 'Calculate the replacement cost using the initial purchase price with accrued interest until the replacement year.'}
]

depreciation_calculation_types = [
  {:active => 1, :name => 'Straight Line',      :class_name => "StraightLineDepreciationCalculator",      :description => 'Calculates the value of an asset using a straight line depreciation method.'},
  {:active => 1, :name => 'Declining Balance',  :class_name => "DecliningBalanceDepreciationCalculator",  :description => 'Calculates the value of an asset using a double declining balance depreciation method.'}
]

service_life_calculation_types = [
  {:active => 1, :name => 'Age Only',          :class_name => 'ServiceLifeAgeOnly',         :description => 'Calculate the replacement year based on the age of the asset.'},
  {:active => 1, :name => 'Condition Only',    :class_name => 'ServiceLifeConditionOnly',   :description => 'Calculate the replacement year based on the condition of the asset.'},
  {:active => 1, :name => 'Age and Condition', :class_name => 'ServiceLifeAgeAndCondition', :description => 'Calculate the replacement year based on the age of the asset or condition whichever minimizes asset life.'},
  {:active => 1, :name => 'Age and Mileage',   :class_name => 'ServiceLifeAgeAndMileage',   :description => 'Calculate the replacement year based on the age of the asset or mileage whichever minimizes asset life.'}
]

condition_estimation_types = [
  {:active => 1, :name => 'Straight Line',  :class_name => 'StraightLineEstimationCalculator',  :description => 'Asset condition is estimated using a straight-line approximation.'},
  {:active => 1, :name => 'TERM',           :class_name => 'TermEstimationCalculator',          :description => 'Asset condition is estimated using FTA TERM approximations.'}
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

task_status_types = [
  {:active => 1, :name => 'Not Started',  :description => 'Not Started.'},
  {:active => 1, :name => 'In Progress',  :description => 'In Progress.'},
  {:active => 1, :name => 'Complete',     :description => 'Complete.'},
  {:active => 1, :name => 'Halted Pending Input',      :description => 'Halted Pending Input.'},
  {:active => 1, :name => 'Cancelled',    :description => 'Cancelled.'}
]

attachment_types = [
  {:active => 1, :name => 'Photo',    :display_icon_name => "fa fa-picture-o",    :description => 'Photo.'},
  {:active => 1, :name => 'Document', :display_icon_name => "fa fa-file-text-o",  :description => 'Scanned document.'}
]

district_types = [
  {:active => 1, :name => 'State',        :description => 'State.'},
  {:active => 1, :name => 'District',     :description => 'Engineering District.'},
  {:active => 1, :name => 'MSA',          :description => 'Metropolitan Statistical Area.'},
  {:active => 1, :name => 'County',       :description => 'County.'},
  {:active => 1, :name => 'City',         :description => 'City.'},
  {:active => 1, :name => 'Borough',      :description => 'Borough.'},
  {:active => 1, :name => 'MPO/RPO',      :description => 'MPO or RPO planning area.'},
  {:active => 1, :name => 'Postal Code',  :description => 'ZIP Code or Postal Area.'}
]

report_types = [
  {:active => 1, :name => 'Inventory Report',     :display_icon_name => "fa fa-bar-chart-o",  :description => 'Inventory Report.'},
  {:active => 1, :name => 'Capital Needs Report', :display_icon_name => "fa fa-usd",          :description => 'Capital Needs Report.'},
  {:active => 1, :name => 'Database Query',       :display_icon_name => "fa fa-database",     :description => 'Custom SQL Report.'}
]

location_reference_types = [
  {:active => 1, :name => 'Well Known Text',        :format => "WELL_KNOWN_TEXT", :description => 'Location is determined by a well known text (WKT) string.'},
  {:active => 1, :name => 'Route/Milepost/Offset',  :format => "LRS",             :description => 'Location is determined by a route milepost and offset.'},
  {:active => 1, :name => 'Street Address',         :format => "ADDRESS",         :description => 'Location is determined by a geocoded street address.'},
  {:active => 1, :name => 'Map Location',           :format => "COORDINATE",      :description => 'Location is determined by deriving a location from a map.'},
  {:active => 1, :name => 'GeoServer',              :format => "GEOSERVER",       :description => 'Location is determined by deriving a location from Geo Server.'}
]

issue_types = [
  {:active => 1, :name => 'Comment',      :description => 'Suggestion'},
  {:active => 1, :name => 'Enhancement',  :description => 'Public Agency (State DOT).'},
  {:active => 1, :name => 'Bug',          :description => 'Bug'},
  {:active => 1, :name => 'Other',        :description => 'Other'}
]

web_browser_types = [
  {:active => 1, :name => 'Microsoft IE 8',      :description => 'IE 8'},
  {:active => 1, :name => 'Microsoft IE 9',      :description => 'IE 9'},
  {:active => 1, :name => 'Microsoft IE 10',     :description => 'IE 10'},
  {:active => 1, :name => 'Microsoft IE 11',     :description => 'IE 11'},
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

lookup_tables = %w{condition_types disposition_types cost_calculation_types license_types priority_types
  file_status_types attachment_types district_types report_types location_reference_types service_status_types
  depreciation_calculation_types task_status_types service_life_calculation_types condition_estimation_types
  issue_types web_browser_types replacement_reason_types
  }

puts ">>> Loading Core Lookup Tables <<<<"
lookup_tables.each do |table_name|
  puts "  Processing #{table_name}"
  if is_mysql
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name};")
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
