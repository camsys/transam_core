class ErrorsController < TransamController
 
  layout "errored"
  
  def show
  	render "#{status_code}.html.haml", :status => status_code
  end

  def system_health
    # send metric to AWS for the number of delayed jobs currently running
    PutMetricDataService.new.put_metric('DelayedJobsRunning', 'Count', Delayed::Job.count)

    # Check to see if delayed jobs needs restarting if locked for at least 8 hours
    @delayed_job_status = "All's well"
    if Delayed::Job.where('locked_at < ?', DateTime.now-8.hours).count > 0
      @delayed_job_status = "Locked"
      unless `ps x | grep delayed | grep -v grep`.present?
        @delayed_job_status = "Not Running"
        `bin/delayed_job restart -n 2`
      end
    end
  end
 
  protected
 
  def status_code
    params[:code] || 500
  end
 
end
