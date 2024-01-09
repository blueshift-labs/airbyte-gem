
module Airbyte
  module V1
    def self.source; Sources.new; end
    class Sources < APIClient
      def create(params)
        body = {
          name: params[:name],
          definitionId: params[:definition_id],
          workspaceId: params[:workspace_id],
          configuration: params[:configuration]
        }
        handle_request(PATH_PREFIX_SOURCES, http_verb: :post, body: body)
      end

      def list(params)
        handle_request(PATH_PREFIX_SOURCES, http_verb: :get, params: params)
      end

      def get(source_id)
        handle_request("#{PATH_PREFIX_SOURCES}/#{source_id}", http_verb: :get)
      end

      def update(params)
        body = {
          name: params[:name],
          configuration: params[:configuration]
        }
        handle_request("#{PATH_PREFIX_SOURCES}/#{params[:source_id]}", http_verb: :put, body: body)
      end

      def delete(source_id)
        handle_request("#{PATH_PREFIX_SOURCES}/#{source_id}", http_verb: :delete)
      end

      def discover_schema(source_id, disable_cache = true)
        Airbyte.source.discover_schema(source_id, disable_cache)
      end

      def get_definition_id(source_name)
        Airbyte.source_definition.get_id(source_name)
      end

      def add_custom_definition_for_workspace(workspace_id, definition_info)
        Airbyte.source_definition.add_custom_definition_for_workspace(workspace_id, definition_info)
      end

      def get_definition_for_workspace(source_name, workspace_id)
        Airbyte.source_definition.get_id_for_workspace(source_name, workspace_id)
      end

      def validate_config(definition_id, workspace_id, connection_config)
        Airbyte.scheduler.validate_source_config(definition_id, workspace_id, connection_config)
      end
    end    
  end
end