
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
        handle_request(PATH_PREFIX_WORKSPACES, http_verb: :post, body: params)
      end

      def delete(workspace_id)
        handle_request("#{PATH_PREFIX_WORKSPACES}/#{workspace_id}", http_verb: :delete)
      end
    end
  end
end