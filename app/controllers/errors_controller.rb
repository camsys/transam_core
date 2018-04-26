class ErrorsController < TransamController
 
  layout "errored"
  
  def show
  	render "#{status_code}.html.haml", :status => status_code
  end

  def system_health
    # return 500 if delayed job been locked for at least 8 hours
    if Delayed::Job.where('locked_at < ?', DateTime.now-8.hours).count > 0
      redirect_to '/500'
    end
  end
 
  protected
 
  def status_code
    params[:code] || 500
  end
 
end