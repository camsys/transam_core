#------------------------------------------------------------------------------
# ServiceStatusUpdateEventLoader
#
# Registers a service status update event against an asset
#
# Inputs: array ['status', 'date']
#
#------------------------------------------------------------------------------
class ServiceStatusUpdateEventLoader < EventLoader

  CURRENT_STATUS_COL    = 0
  EVENT_DATE_COL        = 1

  def process(asset, cells)

    # Create a new ServiceStatusUpdateEvent
    @event = asset.build_typed_event(ServiceStatusUpdateEvent)

    # Current Service Status
    @event.service_status_type = ServiceStatusType.search(cells[CURRENT_STATUS_COL])
    if @event.service_status_type.nil?
      @errors << "Could not find service status type '#{cells[CURRENT_STATUS_COL]}'."
    end

    # Event Date
    temp = as_date(cells[EVENT_DATE_COL])
    u@event.event_date = temp unless temp.nil?

  end

  private
  def initialize
    super
  end

end
