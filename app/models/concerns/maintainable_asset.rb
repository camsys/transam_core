module MaintainableAsset
  #-----------------------------------------------------------------------------
  #
  # MaintainableAsset
  #
  # Mixin that adds maintenance updates to an Asset
  #
  #-----------------------------------------------------------------------------
  extend ActiveSupport::Concern

  included do

    #---------------------------------------------------------------------------
    # Associations
    #---------------------------------------------------------------------------

    # each asset has zero or more condition updates
    has_many   :maintenance_updates, -> {where :asset_event_type_id => MaintenanceUpdateEvent.asset_event_type.id }, :foreign_key => Rails.application.config.asset_base_class_name.foreign_key, :class_name => "MaintenanceUpdateEvent"
    #---------------------------------------------------------------------------
    # Validations
    #---------------------------------------------------------------------------

  end

  #-----------------------------------------------------------------------------
  # Class Methods
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Instance Methods
  #-----------------------------------------------------------------------------

  # Forces an update of an assets reported condition. This performs an update on the record.
  def update_maintenance

    Rails.logger.debug "Updating recorded maintenance for asset = #{object_key}"

    # can't do this if it is a new record as none of the IDs would be set
    unless new_record? or disposed?
      if maintenance_updates.empty?
        self.last_maintenance_date = nil
      else
        event = maintenance_updates.last
        self.last_maintenance_date = event.event_date

        if self.respond_to? :mileage_updates
          # See if there was a mileage update as well but only if this date is later
          # than the last reported mileage date
          if event.current_mileage.to_i > 0 and event.event_date > self.reported_mileage_date
            self.reported_mileage = event.current_mileage.to_i
            self.reported_mileage_date = event.event_date
          end
        end
      end
      # save changes to this asset
      save(:validate => false)
    end

  end
  #-----------------------------------------------------------------------------

end
