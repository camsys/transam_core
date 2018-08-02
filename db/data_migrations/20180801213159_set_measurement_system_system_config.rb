class SetMeasurementSystemSystemConfig < ActiveRecord::DataMigration
  def up
    SystemConfig.instance!(measurement_system: 'imperial')
  end
end