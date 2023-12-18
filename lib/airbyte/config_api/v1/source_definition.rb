
module Airbyte
  def self.source_definition; SourceDefinition.new; end
  class SourceDefinition < ConfigAPIClient
    def list()
      handle_request("source_definitions/list")
    end

    def get_id(source_name)
      resp = list()
      list = resp['sourceDefinitions']
      id = nil
      list.find do |item|
        if item['name'] == source_name
            id = item['sourceDefinitionId']
            break
        end
      end
      id
    end
  end 
end