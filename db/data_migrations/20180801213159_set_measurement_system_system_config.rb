class SetMeasurementSystemSystemConfig < ActiveRecord::DataMigration
  def up
    SystemConfig.instance.update!(measurement_system: 'imperial')
  end
end