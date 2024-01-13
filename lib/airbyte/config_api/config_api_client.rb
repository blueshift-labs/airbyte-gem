require 'net/http'

module Airbyte
  class ConfigAPIClient < BaseClient
    def establish_connection
      Airbyte.connection_config_api.with { |faraday_connection| faraday_connection }
    end

    # Overriding BaseClient method to parse specific response structure
    def get_error_message(json_body)
      return json_body["message"] if json_body["message"]
      super(json_body)
    end
  end
end