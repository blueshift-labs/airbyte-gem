require "faraday"
require "json"
module Airbyte
  def self.destination_definition; DestinationDefinition.new; end
  class DestinationDefinition
    def list_latest(workspace_id)
      params = {
          workspaceId: workspace_id
      }
      response = Airbyte.conn.post do |req|
          req.url "/api/v1/destination_definitions/list_latest"
          req.body = params.to_json
      end
      puts response.status
      JSON.parse(response.body)
  end
  end 
end