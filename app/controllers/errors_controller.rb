class ErrorsController < TransamController
 
  layout "errored"
  
  def show
  	render "#{status_code}.html.haml", :status => status_code
  end

  def system_health
    # send metric to AWS for the number of delayed jobs currently running
    count = Delayed::Job.count
    PutMetricDataService.new.put_metric('DelayedJobsRunning', 'Count', count)

    # Check to see if delayed jobs needs restarting if jobs have been more than half an hour
    @delayed_job_status = "All's well"
    if (count > 0) && Delayed::Job.where('run_at < ?', DateTime.now-30.minutes).exists?
      @delayed_job_status = "Jobs queued longer than threshold"
      unless `ps x | grep delayed | grep -v grep`.present?
        PutMetricDataService.new.put_metric('DelayedJobErrorResponse', 'Count', 1)
        @delayed_job_status = "Not running; attempting to restart"
        pid = Process.spawn('bin/delayed_job restart -n 2')
        Process.detach(pid)
      end
    end
  end
 
  protected
 
  def status_code
    params[:code] || 500
  end
 
end
