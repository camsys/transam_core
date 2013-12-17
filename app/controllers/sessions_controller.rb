class SessionsController < Devise::SessionsController
  after_filter  :log_failed_login, :only => :new
  after_filter  :clear_flash_messages, :only => [:create, :destroy]  
  before_filter :log_logout, :only => :destroy  #add this at the top with the other filters

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
    ::Rails.logger.info "\n***\nSuccessful login with email : #{request.filtered_parameters["email"]}\n***\n"
  end

  protected
  
  def clear_flash_messages
    if flash.keys.include?(:notice)
      flash.delete(:notice)
    end
  end

  private
  
  def log_failed_login
    ::Rails.logger.info "\n***\nFailed login with email : #{request.filtered_parameters["email"]}\n***\n" if failed_login?
  end 

  def failed_login?
    (options = env["warden.options"]) && options[:action] == "unauthenticated"
  end 
  
  def log_logout
     ::Rails.logger.info "*** Logging out : #{current_user.email} ***\n"  
  end
    
end