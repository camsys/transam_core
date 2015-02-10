class ErrorsController < TransamController
 
  layout "errored"
  
  def show
  	render(:file => File.join(Rails.root, 'app/views/errors/#{status_code}.html'), :status => status_code)
  end
 
  protected
 
  def status_code
    params[:code] || 500
  end
 
end
