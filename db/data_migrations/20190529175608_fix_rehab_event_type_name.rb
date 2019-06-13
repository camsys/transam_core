class FixRehabEventTypeName < ActiveRecord::DataMigration
  def up
    aet = AssetEventType.find_by_class_name('RehabilitationUpdateEvent')
    aet.update(name: 'Rebuild / Rehabilitation') if aet
  end
end