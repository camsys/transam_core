#------------------------------------------------------------------------------
#
# Condition Udpate Event Laoder
#
# Used to process both SOGR updates and new inventory updates
#
#------------------------------------------------------------------------------
class ConditionUpdateEventLoader < EventLoader

  CONDITION_RATING_COL       = 0
  EVENT_DATE_COL             = 1

  def process(asset, cells)

    # Create a new ConditionUpdateEvent
    @event = asset.build_typed_event(ConditionUpdateEvent)

    # Condition Rating
    @event.assessed_rating = as_float(cells[CONDITION_RATING_COL]) if cells[CONDITION_RATING_COL]

    # Event Date
    @event.event_date = as_date(cells[EVENT_DATE_COL]) if cells[EVENT_DATE_COL]


  end

  private
  def initialize
    super
  end

end
