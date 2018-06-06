class AddCoreSystemConfigExtensions < ActiveRecord::DataMigration
  def up
    system_config_extensions = [
        {class_name: 'User', extension_name: 'TransamKeywordSearchable'},
        {class_name: 'Vendor', extension_name: 'TransamKeywordSearchable'},
    ]

    system_config_extensions.each do |extension|
      SystemConfigExetnsion.create!(extension)
    end
  end
end