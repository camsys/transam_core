module Api
  ## Base controller for API controllers
  class ApiController < ActionController::API
    include ActionView::Layouts
    layout "jsend"
    
    skip_before_action :authenticate_user!, :verify_authenticity_token, raise: false
    acts_as_token_authentication_handler_for User, fallback: :none
    
    before_action :require_authentication

    respond_to :json

    # Catches 500 errors and sends back JSON with headers.
    include JsonResponseHelper::ApiErrorCatcher 

    before_action :initialize_errors_hash

    def touch_session
      render status: 200,
        json: {}
    end

    protected
    
    # Actions to take after successfully authenticated a user token.
    # This is run automatically on successful token authentication
    def after_successful_token_authentication
      @user = current_user
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

    # Returns true if authentication has successfully completed
    def authentication_successful?
      @user.present?
    end

    # Renders a 401 failure response if authentication was not successful
    def require_authentication
      render_failed_auth_response unless authentication_successful? # render a 401 error
    end

    # Renders a failed user auth response
    def render_failed_auth_response
      render status: 401,
        json: json_response(:fail, data: {user: "Valid email and token must be present."})
    end

  end
end