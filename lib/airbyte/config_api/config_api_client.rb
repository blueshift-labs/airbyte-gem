require 'net/http'

module Airbyte
  class ConfigAPIClient < BaseClient
    def establish_connection
      Airbyte.connection_config_api.with { |faraday_connection| faraday_connection }
    end
  end
end