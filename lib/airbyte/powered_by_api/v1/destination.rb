module Airbyte
  module V1
    def self.destination; Destination.new; end
    class Destination < APIClient
      def create(params)
        body = {
          name: params[:name],
          definitionId: params[:definition_id],
          workspaceId: params[:workspace_id],
          configuration: params[:configuration]
        }
        handle_request(PATH_PREFIX_DESTINATIONS, body: body)
      end

      def update(params)
        body = {
          name: params[:name],
          configuration: params[:configuration]
        }
        handle_request("#{PATH_PREFIX_DESTINATIONS}/#{params[:destination_id]}", http_verb: :put, body: body)
      end

      def delete(destination_id)
        handle_request("#{PATH_PREFIX_DESTINATIONS}/#{destination_id}", http_verb: :delete)
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