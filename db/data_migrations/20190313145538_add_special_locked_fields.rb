class AddSpecialLockedFields < ActiveRecord::DataMigration
  def up
    SystemConfig.instance.update!(special_locked_fields: 'organizations.short_name,organizations.name')
  end
end