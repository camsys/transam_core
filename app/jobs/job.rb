#------------------------------------------------------------------------------
#
# Job
#
# Base class for all jobs. This class represents a generic job that can be run
# by the background processor. All background jobs should be derived from this
# class
#
#------------------------------------------------------------------------------
class Job

  def initialize(*args)

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
      # perform any post processing`
      clean_up
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.warn e.backtrace
      Delayed::Worker.logger.warn e.message rescue nil # log to worker logger if available
      Delayed::Worker.logger.warn e.backtrace rescue nil # log to worker logger if available
    end
  end

  def prepare
  end
  def check
  end
  def clean_up
    #nothing to do
  end

  protected

  # Get the system user
  def get_system_user
    User.where('first_name = ? AND last_name = ?', 'system', 'user').first
  end

end
