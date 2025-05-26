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

    # Override me in subclass to get message from specific result structure.
    def get_error_message(json_result)
      return "Airbyte Request Error"
    end

    def handle_result(result)
      content_type = result.headers['Content-Type']
      unless ['application/json', 'application/problem+json'].include?(content_type) || (200..204).cover?(result.status)
        raise RequestError.new("Airbyte Request Error", result.status, handle_non_utf_chars(result.body))
      end
      json_body = JSON.load(result.body)
      if [200, 204].include?(result.status)
        return json_body
      end
      
      case result.status
      when STATUS_CODE_NOT_ALLOWED
        #$statsd.count("airbyte_client.error.authorization", 1)
        raise AuthorizationError.new(get_error_message(json_body), result.status, json_body)
      when STATUS_CODE_NOT_FOUND
        #$statsd.count("airbyte_client.error.object_not_found", 1)
        raise ObjectNotFoundError.new(get_error_message(json_body), result.status, json_body)
      when STATUS_CODE_INPUT_VALIDATION_FAILED
        #$statsd.count("airbyte_client.error.input_validation", 1)
        raise InputValidationError.new(get_error_message(json_body), result.status, json_body)
      else
        #$statsd.count("airbyte_client.error.request", 1)
        raise RequestError.new(get_error_message(json_body), result.status, json_body)
      end
    end
    def handle_non_utf_chars(str)
      str.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    end
  end
end