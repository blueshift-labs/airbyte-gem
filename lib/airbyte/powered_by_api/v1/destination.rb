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
        resp = handle_request(PATH_PREFIX_DESTINATIONS, body: body)
        unless resp.has_key?("destinationId")
          raise BadRequestError.new("Couldn't create Destination", STATUS_CODE_BAD_REQUEST, resp)
        end
        resp
      end

      def update(params)
        body = {
          name: params[:name],
          configuration: params[:configuration]
        }
        resp = handle_request("#{PATH_PREFIX_DESTINATIONS}/#{params[:destination_id]}", http_verb: :patch, body: body)
        unless resp.has_key?("destinationId")
          raise BadRequestError.new("Couldn't update Destination", STATUS_CODE_BAD_REQUEST, resp)
        end
        resp
      end

      def delete(destination_id)
        handle_request("#{PATH_PREFIX_DESTINATIONS}/#{destination_id}", http_verb: :delete)
      end
      
      def get_definition_id(destination_name)
        resp = Airbyte.destination_definition.get_id(destination_name)
        unless resp
          raise ObjectNotFoundError.new("Couldn't Find Destination Definition: #{destination_name}", STATUS_CODE_NOT_FOUND, resp)
        end
        resp
      end

      def validate_config(definition_id, workspace_id, connection_config)
        resp = Airbyte.scheduler.validate_destination_config(definition_id, workspace_id, connection_config)
        unless resp['jobInfo']['succeeded']
          raise BadRequestError.new(resp["jobInfo"]["failureReason"]["externalMessage"], STATUS_CODE_BAD_REQUEST, resp["jobInfo"])
        end
        unless resp["status"] == "succeeded"
          raise BadRequestError.new(resp["message"], STATUS_CODE_BAD_REQUEST, resp["jobInfo"])
        end
        resp
      end
    end
  end 
end