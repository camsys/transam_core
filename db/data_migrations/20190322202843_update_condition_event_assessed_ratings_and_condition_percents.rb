class UpdateConditionEventAssessedRatingsAndConditionPercents < ActiveRecord::DataMigration
  def up
    ConditionUpdateEvent.all.each do |e|
      e.update!(condition_type: ConditionType.from_rating(e.assessed_rating))
      ConditionTypePercent.where(asset_event_id: e.id).each do |p|
        if p.condition_type_id == e.condition_type_id
          p.update!(pcnt: 100)
        else
          p.update!(pcnt: 0)
        end
      end
    end
  end
end