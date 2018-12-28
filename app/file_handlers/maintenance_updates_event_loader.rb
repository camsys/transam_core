#------------------------------------------------------------------------------
# MaintenanceUpdatesEventLoader
#
# Registers a maintenance update event against an asset
#
#------------------------------------------------------------------------------
class MaintenanceUpdatesEventLoader < EventLoader

  MAINTENANCE_TYPE_COL    = 0
  MILEAGE_COL             = 2
  EVENT_DATE_COL          = 1
  NOTES_COL               = 3

  def process(asset, cells)

    # Create a new ServiceStatusUpdateEvent
    @event = asset.build_typed_event(MaintenanceUpdateEvent)

    # Maintenance Type
    @event.maintenance_type = MaintenanceType.search(cells[MAINTENANCE_TYPE_COL])
    if @event.maintenance_type.nil?
      @errors << "Could not find maintenance type '#{cells[MAINTENANCE_TYPE_COL]}'."
    end

    # Mileage
    mileage = as_integer(cells[MILEAGE_COL])
    @event.current_mileage = mileage if mileage.to_i > 0

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])
    # Notes
    if asset.class.to_s.include? 'Vehicle'
      notes = as_string(cells[NOTES_COL])
    else
      notes = as_string(cells[NOTES_COL-1])
    end
    @event.comments = notes unless notes.blank?

  end

  private
  def initialize
    super
  end

end
