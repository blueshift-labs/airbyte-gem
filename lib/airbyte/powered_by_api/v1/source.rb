
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
        resp = handle_request(PATH_PREFIX_SOURCES, http_verb: :post, body: body)
        unless resp.has_key?("sourceId")
          raise BadRequestError.new("Couldn't create Source", STATUS_CODE_BAD_REQUEST, resp)
        end 
        resp
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
        resp = handle_request("#{PATH_PREFIX_SOURCES}/#{params[:source_id]}", http_verb: :put, body: body)
        unless resp.has_key?("sourceId")
          raise BadRequestError.new("Couldn't update Source", STATUS_CODE_BAD_REQUEST, resp)
        end
        resp
      end

      def delete(source_id)
        handle_request("#{PATH_PREFIX_SOURCES}/#{source_id}", http_verb: :delete)
      end

      def discover_schema(source_id, disable_cache = true)
        Airbyte.source.discover_schema(source_id, disable_cache)
      end

      def get_definition_id(source_name)
        resp = Airbyte.source_definition.get_id(source_name)
        unless resp
          raise ObjectNotFoundError.new("Couldn't Find Source Definition: #{source_name}", STATUS_CODE_NOT_FOUND, resp)
        end
        resp
      end

      def add_custom_definition_for_workspace(workspace_id, definition_info)
        resp = Airbyte.source_definition.add_custom_definition_for_workspace(workspace_id, definition_info)
        unless resp["sourceDefinitionId"]
          raise BadRequestError.new("Couldn't add custom Source definition", STATUS_CODE_BAD_REQUEST, resp)
        end
        resp
      end

      def get_definition_for_workspace(source_name, workspace_id)
        resp = Airbyte.source_definition.get_id_for_workspace(source_name, workspace_id)
        unless resp
          raise ObjectNotFoundError.new("Couldn't Find Source Definition: #{source_name}, for workspace: #{workspace_id}", STATUS_CODE_NOT_FOUND, resp)
        end
        resp
      end

      def validate_config(definition_id, workspace_id, connection_config)
        resp = Airbyte.scheduler.validate_source_config(definition_id, workspace_id, connection_config)
        unless resp['jobInfo']['succeeded']
          raise AuthorizationError.new(resp["jobInfo"]["failureReason"]["externalMessage"], STATUS_CODE_NOT_ALLOWED, resp["jobInfo"])
        end
        unless resp["status"] == "succeeded"
          raise BadRequestError.new(resp["message"], STATUS_CODE_BAD_REQUEST, resp["jobInfo"])
        end
        resp
      end
    end    
  end
end