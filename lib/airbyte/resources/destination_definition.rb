
module Airbyte
  def self.destination_definition; DestinationDefinition.new; end
  class DestinationDefinition < BaseClient
    def list()
      handle_request("/api/v1/destination_definitions/list")
    end
    
    def get_id(destination_name)
      resp = list()
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