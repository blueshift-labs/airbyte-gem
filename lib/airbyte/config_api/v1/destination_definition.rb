
module Airbyte

  def self.destination_definition; DestinationDefinition.new; end
  class DestinationDefinition < ConfigAPIClient
    def list()
      handle_request("#{PATH_PREFIX_DESTINATION_DEFINITIONS}/list")
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