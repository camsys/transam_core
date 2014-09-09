#------------------------------------------------------------------------------
#
# ProcessLog
#
# Holds all processing messages for a bulk update
# and the DSL to create or view them
#
#------------------------------------------------------------------------------
class ProcessLog

  attr_reader :process_log

  def initialize
    @process_log = []
    @log_level = 1
  end

  # Adds a message to the process log
  def add_processing_message(level, severity, text)
    
    # See if we are bumping the level up or down
    if @log_level < level
      while @log_level < level
        @process_log << "<ul>"
        @log_level += 1
      end
    elsif @log_level > level
      while @log_level > level
        @process_log << "</ul>"
        @log_level -= 1
      end
    end
    @log_level = level
    
    # Log Level 1 is a special case for top-level information.  
    # All other levels are subordinate to some larger piece (e.g. MileageUpdate processing)
    if level == 1
      @process_log << "<p class='text-#{severity}'>#{text}</p>" 
    else
      @process_log << "<li><p class='text-#{severity}'>#{text}</p></li>"
    end
  end

  def to_s
    @process_log.join('')
  end

  def empty?
    @process_log.empty?
  end
end