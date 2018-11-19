module Api
  ## Base controller for API controllers
  class ApiController < ActionController::API
    include ActionView::Layouts
    
    layout "jsend"
    
    acts_as_token_authentication_handler_for User, fallback: :none
    respond_to :json

    # Catches 500 errors and sends back JSON with headers.
    include JsonResponseHelper::ApiErrorCatcher 

    before_action :initialize_errors_hash

    protected
    
    # Actions to take after successfully authenticated a user token.
    # This is run automatically on successful token authentication
    def after_successful_token_authentication
      return nil unless auth_headers.present? && auth_headers[:email] && auth_headers[:authentication_token]
      @user = User.find_by(email: auth_headers[:email], 
                           authentication_token: auth_headers[:authentication_token]) ||
              @user
    end

    # Initializes an empty errors hash, before each action
    def initialize_errors_hash
      @errors = {}
    end

    # Returns a hash of authentication headers
    def auth_headers
      {
        email: request.headers["X-User-Email"], 
        authentication_token: request.headers["X-User-Token"]
      }
    end

  end
end