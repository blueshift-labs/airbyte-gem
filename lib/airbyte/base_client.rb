require 'net/http'

module Airbyte
  class RequestError < StandardError

    attr_reader :body

    def initialize(msg, body)
      super(msg)
      @body = body
    end

  end

  class ConnectionError < StandardError
  end

  class BaseClient

    def handle_request(url, http_verb: :post, params: nil, body: nil)
      begin
        result = nil
        Airbyte.connection.with do |faraday_connection|
          result = faraday_connection.send(http_verb.to_s) do |request|
            request.url url
            request.headers['Content-Type'] = 'application/json'
            request.params = params unless params.nil?
            request.body = body.to_json unless body.nil?
            request.options[:timeout] = 600
          end
        end
        handle_result(result)
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed => ex
        raise ConnectionError.new("Airbyte connection error: #{ex.message}")
      end
    end

    def handle_request_with_headers(url, http_verb, params: nil, body: nil)
      raise StandardError.new("Unstubbed Airbyte call from test") if Rails.env.test?
      result = nil
      Airbyte.connection.with do |faraday_connection|
        result = faraday_connection.send(http_verb.to_s) do |request|
          request.url url
          request.headers['Content-Type'] = 'application/json'
          request.params = params unless params.nil?
          request.body = body.to_json unless body.nil?
          request.options[:timeout] = 600
        end
      end
      body = JSON.load(result.body) rescue nil
      return body, result.headers
    end

    def handle_result(result)
      if [200, 204, 404].include? result.status
        JSON.load(result.body)
      else
        raise RequestError.new("Airbyte error status=#{result.status} #{JSON.load(result.body)}", result.body)
      end
    end
  end

end