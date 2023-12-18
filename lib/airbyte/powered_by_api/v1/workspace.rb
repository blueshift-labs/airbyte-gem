
module Airbyte
  module V1
    def self.workspace; Workspace.new; end
    class Workspace < APIClient
      def list
        handle_request(RESOURCE_PATH_WORKSPACES, http_verb: :get)
      end

      def create(name)
        params = {
            name: name,
        }
        handle_request(RESOURCE_PATH_WORKSPACES, http_verb: :post, body: params)
      end

      def delete(workspace_id)
        path = "#{RESOURCE_PATH_WORKSPACES}/#{workspace_id}"
        handle_request(path, http_verb: :delete)
      end
    end
  end
end