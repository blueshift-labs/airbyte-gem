module Airbyte
  STATUS_CODE_BAD_REQUEST = 400
  STATUS_CODE_NOT_ALLOWED = 403
  STATUS_CODE_NOT_FOUND = 404
  STATUS_CODE_INPUT_VALIDATION_FAILED = 422
  
  class RequestError < StandardError
    attr_reader :body, :message, :status_code
    def initialize(msg, code, body)
      super(msg)
      @body = body
      @message = msg
      @status_code = code
    end 
  end
  
  class BadRequestError < RequestError; end
  class AuthorizationError < RequestError; end
  class InputValidationError < RequestError; end
  class ObjectNotFoundError < RequestError; end
  class ConnectionError < StandardError; end
end