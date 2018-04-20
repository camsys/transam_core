class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  # This method is called after a sucessful login by a user. The call comes from
  # SessionsController:create
  def create_user_session

    # Set up the user's session

    # placeholder

  end

  # Returns true if the request was an ajax request
  def ajax_request?
    request.xhr?
  end
end
