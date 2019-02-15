class AddCoreEngineNameSystemConfigExtensions < ActiveRecord::DataMigration
  def up
    system_config_extensions = [
        {class_name: Rails.application.config.asset_base_class_name, extension_name: 'TransamKeywordSearchable', active: true},
        {class_name: 'User', extension_name: 'TransamKeywordSearchable', active: true},
        {class_name: 'Vendor', extension_name: 'TransamKeywordSearchable', active: true}
    ]

    system_config_extensions << {class_name: 'AssetMapSearcher', extension_name: 'CoreAssetMapSearchable', active: true} if SystemConfig.transam_module_loaded? :spatial


    system_config_extensions.each do |config|
      SystemConfigExtension.find_by(config).update!(engine_name: 'core')
    end
  end
end