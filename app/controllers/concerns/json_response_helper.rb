module JsonResponseHelper


  # Formats a JSON response using the JSend specification
  def json_response(status, body={})
    body = body.with_indifferent_access
    return body.merge({status: status.to_s})
  end

  module ApiErrorCatcher

    # Catch internal errors gracefully and send back a 500 response with JSON and proper headers
    def self.included(base)
      # Catches server errors so that response can be rendered as JSON with proper headers, etc.
      if base < ActionController::API
        base.rescue_from Exception, with: :api_error_response
      end

      base.include JsonResponseHelper
    end

    # Rescues 500 errors and renders them properly as JSON response
    def api_error_response(exception)
      exception.backtrace.each { |line| logger.error line }
      error_response = {
        message: exception.message,
        data: { type: exception.class.name, message: exception.message }
      }
      render status: 500, json: json_response(:error, error_response)
    end



  end

  # For catching JSON parser errors when client sends an invalid JSON request
  # This class is applied to the middleware stack in application.rb
  class CatchJsonParseErrors
    include JsonResponseHelper

    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        @app.call(env)
      rescue ActionDispatch::Http::Parameters::ParseError => error
        if env['CONTENT_TYPE'] =~ /application\/json/
          error_output = {request: "There was a problem in the JSON you submitted.", error: error}
          return [
            400, {"Content-Type" => "application/json; charset=utf-8"},
            [ json_response(:fail, data: error_output).to_json ]
          ]
        else
          raise error
        end
      end
    end
  end


end
