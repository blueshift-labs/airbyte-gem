require 'net/http'

module Airbyte
  class APIClient < BaseClient
    def establish_connection
      Airbyte.connection_airbyte_api.with { |faraday_connection| faraday_connection }
    end
  end
end