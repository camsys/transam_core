#------------------------------------------------------------------------------
#
# Job
#
# Base class for all jobs. This class represents a generic job that can be run
# by the background processor. All background jobs should eb derived from this
# class
#
#------------------------------------------------------------------------------
class Job
  
  def initialize
    
  end
  
  # Called by the delayed_jobs scheduler to execute a job
  def perform
    begin
      # prepare the job
      prepare
      # check that everything is kosher
      check
      # run the job
      run
    rescue Exception => e
      Rails.logger.warn e.message      
    end
  end
end