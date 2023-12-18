module Airbyte
  module V1
    def self.destination; Destination.new; end
    class Destination < APIClient
      def create(params)
        handle_request(RESOURCE_PATH_DESTINATIONS, body: params)
      end

      def update(params)
        handle_request(RESOURCE_PATH_DESTINATIONS, body: params)
      end

      def delete(destination_id)
        handle_request("#{RESOURCE_PATH_DESTINATIONS}/#{destination_id}", http_verb: :delete)
      end
      
      def get_definition_id(source_name)
        Airbyte.destination_definition.get_id(source_name)
      end

      def validate_config(definition_id, workspace_id, connection_config)
        Airbyte.scheduler.validate_destination_config(definition_id, workspace_id, connection_config)
      end
    end
  end 
end