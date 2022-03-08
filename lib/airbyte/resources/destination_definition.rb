require "faraday"
require "json"
module Airbyte
  def self.destination_definition; DestinationDefinition.new; end
  class DestinationDefinition < BaseClient
    def list_latest(workspace_id)
      params = {
          workspaceId: workspace_id
      }
      handle_request("/api/v1/destination_definitions/list_latest", body: params)
    end
    
    def get_id(workspace_id, destination_name)
      resp = list_latest(workspace_id)
      list = resp['destinationDefinitions']
      id = nil
      list.each do |item|
          if item['name'] == destination_name
            id = item['destinationDefinitionId']
            break
          end
      end
      id
    end
  end 
end