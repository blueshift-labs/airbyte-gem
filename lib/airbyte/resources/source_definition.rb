
module Airbyte
  def self.source_definition; SourceDefinition.new; end
  class SourceDefinition < BaseClient
    def list()
      handle_request("/api/v1/source_definitions/list")
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