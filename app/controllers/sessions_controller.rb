require 'browser'

class SessionsController < Devise::SessionsController
  
  after_action  :log_failed_login, :only => :new
  after_action  :clear_flash_messages, :only => [:create, :destroy]
  before_action :log_logout, :only => :destroy

  # determine which layout to use based on the current user state
  layout :layout_by_resource

  # Determine which layout to use based on the authorized state
  def layout_by_resource
    if user_signed_in?
      "application"
    else
      "unauthorized"
    end
  end       

  # POST /resource/sign_in
  def create
    super
    Rails.logger.info "Successful login with email : #{current_user.email} at #{Time.now}"
    
    Rails.logger.debug "Configuring session for : #{current_user.name}"
    
    # This must be configured in the Application Controller
    create_user_session

    browser = Browser.new(request.env['HTTP_USER_AGENT'], accept_language: "en-us")
    if browser.chrome?
      browser_string = 'Chrome'
    elsif browser.firefox?
      browser_string = 'Firefox'
    elsif browser.safari?
      browser_string = 'Safari'
    elsif browser.edge?
      browser_string = 'IE Edge'
    elsif browser.ie?(6)
      browser_string = 'IE 6'
    elsif browser.ie?(7)
      browser_string = 'IE 7'
    elsif browser.ie?(8)
      browser_string = 'IE 8'
    elsif browser.ie?(9)
      browser_string = 'IE 9'
    elsif browser.ie?(10)
      browser_string = 'IE 10'
    elsif browser.ie?(11)
      browser_string = 'IE 11'
    elsif browser.ie?
      browser_string = 'IE (Other)'
    else
      browser_string = 'Other'
    end

    PutMetricDataService.new.put_metric('BrowserCount', 'Count', 1, [
        {
            'Name' => 'Browser Type',
            'Value' => browser_string
        },
        {
            'Name' => 'Email Domain',
            'Value' => current_user.email.split('@')[1]
        },
    ])

    Rails.logger.debug "Session configured"
       
  end

  protected
  
  def clear_flash_messages
    if flash.keys.include?(:notice)
      flash.delete(:notice)
    end
  end

  private
  
  def log_failed_login
    Rails.logger.info "Failed login with email: #{params['user']['email']} at #{Time.now}" if failed_login?
  end 

  def failed_login?
    (options = request.env["warden.options"]) && options[:action] == "unauthenticated"
  end 
  
  def log_logout
    Rails.logger.info "Logout for user with email: #{current_user.email} at #{Time.now}"
  end
    
end