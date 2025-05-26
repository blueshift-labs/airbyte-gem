
module Airbyte
  module V1
    def self.workspace; Workspace.new; end
    class Workspace < APIClient
      def list
        handle_request(PATH_PREFIX_WORKSPACES, http_verb: :get)
      end

      def create(name)
        params = {
            name: name,
        }
        resp = handle_request(PATH_PREFIX_WORKSPACES, http_verb: :post, body: params)
        unless resp["workspaceId"]
          raise BadRequestError.new("Couldn't create workspace", STATUS_CODE_BAD_REQUEST, resp)
        end
        resp
      end

      def delete(workspace_id)
        handle_request("#{PATH_PREFIX_WORKSPACES}/#{workspace_id}", http_verb: :delete)
      end
    end
  end
end