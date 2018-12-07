#------------------------------------------------------------------------------
#
# DispositionUpdateEventLoader
#
# Generic class for processing usage update events
#
#------------------------------------------------------------------------------
class DispositionUpdateEventLoader < EventLoader

  EVENT_DATE_COL        = 1
  DISPOSITION_TYPE_COL  = 0
  SALES_PROCEEDS_COL    = 2
  MILEAGE_COL           = 3

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

  end

  private
  def initialize
    super
  end

end
