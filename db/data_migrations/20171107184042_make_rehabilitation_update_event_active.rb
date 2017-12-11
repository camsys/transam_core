class MakeRehabilitationUpdateEventActive < ActiveRecord::DataMigration
  def up
    AssetEventType.find_by(class_name: 'RehabilitationUpdateEvent').update!(active: true)
  end
end