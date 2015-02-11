class ErrorsController < TransamController
 
  layout "errored"
  
  def show
  	render "#{status_code}.html.erb", :status => status_code
  end
 
  protected
 
  def status_code
    params[:code] || 500
  end
 
end