module Airbyte
  def self.scheduler; Scheduler.new; end
  class Scheduler < ConfigAPIClient
    def validate_source_config(source_definition_id, workspace_id, connection_config)
      source_config = {
        sourceDefinitionId: source_definition_id,
        workspaceId: workspace_id,
        connectionConfiguration: connection_config
      }
      handle_request("#{PATH_PREFIX_SCHEDULER_SOURCE}/check_connection", body: source_config)
    end
    def validate_destination_config(destination_definition_id, workspace_id, connection_config)
      destination_config = {
        destinationDefinitionId: destination_definition_id,
        workspaceId: workspace_id,
        connectionConfiguration: connection_config
      }
      handle_request("#{PATH_PREFIX_SCHEDULER_DESTINATION}/check_connection", body: destination_config)
    end
  end 
end