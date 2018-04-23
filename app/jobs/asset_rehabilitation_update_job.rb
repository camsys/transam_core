#------------------------------------------------------------------------------
#
# AssetRehabilitationUpdateJob
#
# Updates an assets rehabilitation ststus
#
#------------------------------------------------------------------------------
class AssetRehabilitationUpdateJob < AbstractAssetUpdateJob

  def requires_sogr_update?
    false # manually call it in job so can perform update rehab actions in correct order
  end

  def execute_job(asset)
    asset.update_rehabilitation

    asset.update_sogr

    update_sched_replacement_yr = false

    if asset.rehabilitation_updates.empty?
      update_sched_replacement_yr = true
    else
      last_rehab = asset.rehabilitation_updates.last
      if last_rehab.extended_useful_life_months > 0 || (last_rehab.try(:extended_useful_life_miles) || 0) > 0
        update_sched_replacement_yr = true
      end
    end

    if update_sched_replacement_yr
      asset.update(scheduled_replacement_year: asset.policy_replacement_year)
    end

  end

  def prepare
    Rails.logger.debug "Executing AssetRehabilitationUpdateJob at #{Time.now.to_s} for Asset #{object_key}"
  end

end
