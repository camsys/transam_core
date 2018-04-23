#------------------------------------------------------------------------------
#
# DispositionUpdateEventLoader
#
# Generic class for processing usage update events
#
#------------------------------------------------------------------------------
class EarlyDispositionRequestUpdateEventLoader < EventLoader

  EXPLANATION_COL  = 0
  EVENT_DATE_COL        = 1
  SALES_PROCEEDS_COL    = 2
  MILEAGE_COL           = 3

  def process(asset, cells)

    # Create a new DispositionUpdateEvent
    @event = asset.build_typed_event(EarlyDispositionRequestUpdateEvent)

    # Event Date
    @event.event_date = Date.today

    # Disposition Type
    @event.comments = as_string(cells[EXPLANATION_COL])

  end

  private
  def initialize
    super
  end

end
