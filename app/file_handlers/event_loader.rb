#------------------------------------------------------------------------------
#
# EventLoader
#
# Abstract base class for a loader that process events. 
#
#------------------------------------------------------------------------------
class EventLoader < InventoryLoader
    
  def event
    @event
  end
  
  protected
  
  private
  
  def initialize
    super
    @event = nil
  end
  
end