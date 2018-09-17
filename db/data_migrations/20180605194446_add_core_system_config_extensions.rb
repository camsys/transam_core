class AddCoreSystemConfigExtensions < ActiveRecord::DataMigration
  def up
    system_config_extensions = [
        {class_name: 'TransamAsset', extension_name: 'TransamKeywordSearchable', active: true},
        {class_name: 'User', extension_name: 'TransamKeywordSearchable', active: true},
        {class_name: 'Vendor', extension_name: 'TransamKeywordSearchable', active: true},
    ]

    system_config_extensions.each do |extension|
      SystemConfigExtension.create!(extension)
    end
  end
end