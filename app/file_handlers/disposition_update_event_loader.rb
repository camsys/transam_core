#------------------------------------------------------------------------------
#
# DispositionUpdateEventLoader
#
# Generic class for processing usage update events
#
#------------------------------------------------------------------------------
class DispositionUpdateEventLoader < EventLoader

  EVENT_DATE_COL        = 0
  DISPOSITION_TYPE_COL  = 1
  SALES_PROCEEDS_COL    = 2
  AGE_COL               = 3
  MILEAGE_COL           = 4
  NEW_OWNER_NAME_COL    = 5
  NEW_OWNER_ADDRESS_COL = 6
  NEW_OWNER_CITY_COL    = 7
  NEW_OWNER_STATE_COL   = 8
  NEW_OWNER_ZIP_COL     = 9
  COMMENTS_COL          = 10

  def process(asset, cells)

    # Create a new DispositionUpdateEvent
    @event = asset.build_typed_event(DispositionUpdateEvent)

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL])

    # Disposition Type
    val = as_string(cells[DISPOSITION_TYPE_COL])
    @event.disposition_type = DispositionType.search(val)
    if @event.disposition_type.nil?
      @errors << "Dispositon Type not found or missing. Type = #{val}."
    end

    # Sales Proceeds
    @event.sales_proceeds = as_integer(cells[SALES_PROCEEDS_COL])

    # Age at disposition
    @event.age_at_disposition = as_integer(cells[AGE_COL])

    # Mileage at disposition
    @event.mileage_at_disposition = as_integer(cells[MILEAGE_COL])

    # New Owner Name
    @event.new_owner_name = as_string(cells[NEW_OWNER_NAME_COL])

    # New Owner Address
    @event.address1 = as_string(cells[NEW_OWNER_ADDRESS_COL])

    # New Owner City
    @event.city = as_string(cells[NEW_OWNER_CITY_COL])

    # New Owner State
    @event.state = as_string(cells[NEW_OWNER_STATE_COL])

    # New Owner Zip
    @event.zip = as_string(cells[NEW_OWNER_ZIP_COL])

    # Comments
    @event.comments = as_string(cells[COMMENTS_COL])

  end

  private
  def initialize
    super
  end

end
