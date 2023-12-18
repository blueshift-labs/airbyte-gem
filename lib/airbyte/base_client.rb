module Airbyte
  class BaseClient
    def handle_request(url, http_verb: :post, params: nil, body: nil)
      begin
        result = nil
        faraday_connection = establish_connection
        result = faraday_connection.send(http_verb.to_s) do |request|
          request.url url
          request.headers['Content-Type'] = 'application/json'
          request.params = params unless params.nil?
          request.body = body.to_json unless body.nil?
          request.options[:timeout] = 600
        end
        handle_result(result)
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed => ex
        raise ConnectionError.new("Airbyte connection error: #{ex.message}")
      end
    end

    def handle_result(result)
      json_body = JSON.load(result.body)
      if [200, 204].include?(result.status)
        json_body
      elsif result.status == STATUS_NOT_ALLOWED
        raise AuthorizationError.new(json_body["message"], result.status, json_body)
      elsif result.status == STATUS_NOT_FOUND
        raise ObjectNotFoundError.new(json_body["message"], result.status, json_body)
      elsif result.status == STATUS_INPUT_VALIDATION_FAILED
        raise InputValidationError.new(json_body["message"], result.status, json_body)
      else
        raise RequestError.new("Airbyte Request error", result.status, json_body)
      end
    end
  end
end