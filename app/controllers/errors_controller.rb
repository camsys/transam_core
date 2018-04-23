class ErrorsController < TransamController
 
  layout "errored"
  
  def show
  	render "#{status_code}.html.haml", :status => status_code
  end

  def system_health
    unless Delayed::Job.where('locked_at IS NOT NULL').count > 0 || Delayed::Job.count == 0
      redirect_to '/500'
      return
    end
  end
 
  protected
 
  def status_code
    params[:code] || 500
  end
 
end