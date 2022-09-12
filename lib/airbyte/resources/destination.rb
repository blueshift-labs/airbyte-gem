module Airbyte
  def self.destination; Destination.new; end
  class Destination < BaseClient
    def create(params)
      handle_request("/api/v1/destinations/create", body: params)
    end

    def update(params)
      handle_request("/api/v1/destinations/update", body: params)
    end

    def delete(destination_id)
      params = {
        destinationId: destination_id
      }
      handle_request("/api/v1/destinations/delete", body: params)
    end
    
    def get_definition_id(source_name)
      Airbyte.destination_definition.get_id(source_name)
    end

    def validate_config(definition_id, connection_config)
      Airbyte.scheduler.validate_destination_config(definition_id, connection_config)
    end
  end 
end