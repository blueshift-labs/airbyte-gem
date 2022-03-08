require "faraday"
require "json"
module Airbyte
  def self.source_definition; SourceDefinition.new; end
  class SourceDefinition < BaseClient
    def list_latest(workspace_id)
      params = {
          workspaceId: workspace_id
      }
      handle_request("/api/v1/source_definitions/list_latest", body: params)
    end

    def get_id(workspace_id, source_name)
      resp = list_latest(workspace_id)
      list = resp['sourceDefinitions']
      id = nil
      list.each do |item|
        if item['name'] == source_name
            id = item['sourceDefinitionId']
            break
        end
      end
      id
    end
  end 
end