require "faraday"
require "json"
module Airbyte
  def self.scheduler; Scheduler.new; end
  class Scheduler < BaseClient
    def validate_source_config(source_definition_id, params)
      connection_config = {
        role: params[:role],
        warehouse: params[:warehouse],
        database: params[:database],
        schema: params[:schema],
        password: params[:password],
        username: params[:username],
        host: params[:host]
      }
      source_config = {
        sourceDefinitionId: source_definition_id,
        connectionConfiguration: connection_config
      }
      handle_request("/api/v1/scheduler/sources/check_connection", body: source_config)
    end
    def validate_destination_config(destination_definition_id, connection_config)
      destination_config = {
        destinationDefinitionId: destination_definition_id,
        connectionConfiguration: connection_config
      }
      handle_request("/api/v1/scheduler/destinations/check_connection", body: destination_config)
    end
  end 
end