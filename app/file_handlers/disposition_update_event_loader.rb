#------------------------------------------------------------------------------
#
# DispositionUpdateEventLoader
#
# Generic class for processing usage update events
#
#------------------------------------------------------------------------------
class DispositionUpdateEventLoader < EventLoader

  EVENT_DATE_COL          = 0
  DISPOSITION_TYPE_COL    = 1
  SALES_PROCEEDS_COL      = 2
  NEW_OWNER_NAME_COL      = 3
  NEW_OWNER_ADDRESS_COL   = 4
  MILEAGE_AT_DISPOSITION  = 5

  def process(asset, cells)

    # Create a new DispositionUpdateEvent
    @event = asset.build_typed_event(DispositionUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])

    # Disposition Type
    val = as_string(cells[DISPOSITION_TYPE_COL])
    @event.disposition_type = DispositionType.search(val)
    if @event.disposition_type.nil?
      @errors << "Disposition Type '#{val}' not found or missing. Defaulting to Sold at Public Auction."
      @event.disposition_type = DispositionType.find_by(:code => 'P')
    end

    # Sales Proceeds
    @event.sales_proceeds = as_integer(cells[SALES_PROCEEDS_COL])

    # New Owner Name
    @event.new_owner_name = as_string(cells[NEW_OWNER_NAME_COL])

    # New Owner Address
    @event.address1 = as_string(cells[NEW_OWNER_ADDRESS_COL])

    # Current Mileage
    if asset.type_of? :vehicle or asset.type_of? :support_vehicle
      @event.mileage_at_disposition = as_integer(cells[MILEAGE_AT_DISPOSITION])
    end

    # Age
    @event.age_at_disposition = asset.age(@event.event_date)

  end

  private
  def initialize
    super
  end

end
