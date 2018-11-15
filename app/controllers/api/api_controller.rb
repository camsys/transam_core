## Base controller for API controllers
class Api::ApiController < ActionController::API
  include ActionView::Layouts
  
  layout "jsend"
  
  # protect_from_forgery prepend: true
  # acts_as_token_authentication_handler_for User, fallback: :none
  respond_to :json
  
end
