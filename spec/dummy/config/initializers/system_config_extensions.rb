Rails.configuration.to_prepare do
  begin
    if ActiveRecord::Base.connection.table_exists?(:system_config_extensions)
      SystemConfigExtension.all.each do |extension|
        extension.class_name.constantize.class_eval do
          include extension.extension_name.constantize
        end
      end
    end
  rescue ActiveRecord::NoDatabaseError
    puts "no database so not loading system config extensions"
  end
end
