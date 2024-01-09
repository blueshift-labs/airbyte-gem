module Airbyte
  class BaseClient
    def do_handle_request(url, http_verb, params, body)
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
    end

    def handle_request(url, http_verb: :post, params: nil, body: nil, max_retries: 5)
      retry_count = 0
      begin
        do_handle_request(url, http_verb, params, body)
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed => ex
        retry_count += 1
        if retry_count <= max_retries
          sleep(rand(5))
          #$statsd.increment("airbyte_client.http.error.retry")
          retry
        end
        #$statsd.increment("airbyte_client.http.error.retry_exhausted")
        raise ConnectionError.new("Airbyte connection error: #{ex.message}")
      end
    end

    def handle_result(result)
      content_type = result.headers['Content-Type']
      if content_type != 'application/json' && !(200..204).cover?(result.status)
        raise RequestError.new("Airbyte Request error", result.status, result.body)
      end
      json_body = JSON.load(result.body)
      if [200, 204].include?(result.status)
        json_body
      elsif result.status == STATUS_NOT_ALLOWED
        #$statsd.count("airbyte_client.error.authorization", 1)
        raise AuthorizationError.new(json_body["message"], result.status, json_body)
      elsif result.status == STATUS_NOT_FOUND
        #$statsd.count("airbyte_client.error.object_not_found", 1)
        raise ObjectNotFoundError.new(json_body["message"], result.status, json_body)
      elsif result.status == STATUS_INPUT_VALIDATION_FAILED
        #$statsd.count("airbyte_client.error.input_validation", 1)
        raise InputValidationError.new(json_body["message"], result.status, json_body)
      else
        #$statsd.count("airbyte_client.error.request", 1)
        raise RequestError.new("Airbyte Request error", result.status, json_body)
      end
    end
  end
end