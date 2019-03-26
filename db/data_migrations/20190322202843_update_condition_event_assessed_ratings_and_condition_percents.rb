class UpdateConditionEventAssessedRatingsAndConditionPercents < ActiveRecord::DataMigration
  def up
    ConditionUpdateEvent.joins(:base_transam_asset).where("transam_assets.purchased_new = 1 AND asset_events.event_date < transam_assets.purchase_date")

    ConditionUpdateEvent.where(transam_asset: purchased_new).each do |e|
      if e.event_date < e.transam_asset.try(:purchase_date)
        e.update_(event_date: e.transam_asset.purchase_date)
      end
    end

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