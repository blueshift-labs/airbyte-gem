require 'net/http'

module Airbyte
  class APIClient < BaseClient
    def establish_connection
      Airbyte.connection_airbyte_api.with { |faraday_connection| faraday_connection }
    end

    # Overriding BaseClient method to parse specific response structure
    def get_error_message(json_body)
      return json_body["detail"] if json_body["detail"]
      super(json_body)
    end
  end
end