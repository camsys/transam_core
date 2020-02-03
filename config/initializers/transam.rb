# Check that we got loaded from application.yml

# General UI configuration settings
Rails.application.config.ui_typeahead_delay = 300       # milliseconds delay between keystrokes before a query is sent to the server to retrieve a typeahead list
Rails.application.config.ui_typeahead_min_chars = 1     # minimum number of characters to initiate a query
Rails.application.config.ui_typeahead_list_length = 10  # max number of items displayed in the typeahead list
Rails.application.config.ui_search_items = 10           # max number of matching things to return in a search
Rails.application.config.ui_min_geocode_chars = 5       # Minimum number of characters (not including whitespace) before sending to the geocoder

Rails.application.config.object_cache_expire_seconds = 300 # seconds to keep objects stored in the cache
Rails.application.config.max_rows_returned = 500          # maximum number of rows to return from a database query

Rails.application.config.max_upload_file_size = 4          # maximum file size able to be uploaded
Rails.application.config.epoch = Date.new(1900,1,1)      # epoch


begin
  if ActiveRecord::Base.connection.table_exists?(:system_config_extensions)
    Rails.application.config.transam_keyword_searchable_classes = SystemConfigExtension.where(active: true, extension_name: 'TransamKeywordSearchable').pluck(:class_name)
  end
rescue ActiveRecord::NoDatabaseError
  puts "no database so not loading system config extensions"
end


Rails.application.config.rails_admin_core_lookup_tables = ['AssetEventType', 'AssetType', 'AssetSubtype', 'ConditionType', 'DispositionType', 'DistrictType', 'FrequencyType', 'FundingTemplateType','IssueType', 'LicenseType', 'LocationReferenceType', 'MaintenanceType', 'ManufacturerModel', 'NoticeType','PriorityType', 'ReportType', 'ServiceStatusType', 'WebBrowserType', 'SystemConfigFieldCustomization']
Rails.application.config.rails_admin_core_models = ['Asset', 'AssetGroup', 'Comment', 'Document', 'FundingTemplate', 'Image', 'Manufacturer', 'Organization','Report', 'Role', 'User', 'Vendor']

Rails.application.config.assets.precompile += %w( transam_banner_1.jpg transam_banner_2.jpg transam_banner_3.jpg transam_banner_4.jpg )