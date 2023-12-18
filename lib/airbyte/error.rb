module Airbyte
  STATUS_NOT_ALLOWED = 403
  STATUS_NOT_FOUND = 404
  STATUS_INPUT_VALIDATION_FAILED = 422
  
  class RequestError < StandardError
    attr_reader :body, :message, :status_code
    def initialize(msg, code, body)
      super(msg)
      @body = body
      @message = msg
      @status_code = code
    end 
  end
  
  class AuthorizationError < RequestError; end
  class InputValidationError < RequestError; end
  class ObjectNotFoundError < RequestError; end
end