module Airbyte
  def self.scheduler; Scheduler.new; end
  class Scheduler < BaseClient
    def validate_source_config(source_definition_id, workspace_id, connection_config)
      source_config = {
        sourceDefinitionId: source_definition_id,
        workspaceId: workspace_id,
        connectionConfiguration: connection_config
      }
      handle_request("/api/v1/scheduler/sources/check_connection", body: source_config)
    end
    def validate_destination_config(destination_definition_id, workspace_id, connection_config)
      destination_config = {
        destinationDefinitionId: destination_definition_id,
        workspaceId: workspace_id,
        connectionConfiguration: connection_config
      }
      handle_request("/api/v1/scheduler/destinations/check_connection", body: destination_config)
    end
  end 
end