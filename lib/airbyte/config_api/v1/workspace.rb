
module Airbyte
  def self.workspace; Workspace.new; end
  class Workspace < ConfigAPIClient
    def list
      handle_request("#{PATH_PREFIX_WORKSPACES}/list")
    end

    def create(email, name)
      params = {
          email: email,
          anonymousDataCollection: false,
          name: name,
          news: false,
          securityUpdates: false,
      }
      handle_request("#{PATH_PREFIX_WORKSPACES}/create", body: params)
    end

    def delete(workspace_id)
      params = {
        "workspaceId": workspace_id
      }
      handle_request("#{PATH_PREFIX_WORKSPACES}/delete", body: params)
    end
  end 
end