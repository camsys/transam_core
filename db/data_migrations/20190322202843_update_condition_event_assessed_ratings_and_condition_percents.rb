class UpdateConditionEventAssessedRatingsAndConditionPercents < ActiveRecord::DataMigration
  def up
    ConditionUpdateEvent.joins(:base_transam_asset).where("transam_assets.purchased_new = 1 AND asset_events.event_date < transam_assets.purchase_date")
      .each do |e|
        e.update_columns(event_date: e.transam_asset.purchase_date)
      end


    ConditionUpdateEvent.joins(:base_transam_asset).each do |e|
      e.update_columns(condition_type_id: ConditionType.from_rating(e.assessed_rating).id)
    end

    ConditionTypePercent.joins(:condition_update_event).where("condition_type_percents.condition_type_id = asset_events.condition_type_id")
      .update_all(pcnt: 100)
    ConditionTypePercent.joins(:condition_update_event).where.not("condition_type_percents.condition_type_id = asset_events.condition_type_id")
      .update_all(pcnt: 0)
  end
end