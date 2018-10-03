class CleanupFrequenecyTypes < ActiveRecord::DataMigration
  def up
    FrequencyType.create({:active => 1, :name => 'hour', :description => 'Hour'})
  end
end