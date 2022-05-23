
module Airbyte
  def self.workspace; Workspace.new; end
  class Workspace < BaseClient
    def list
      handle_request("/api/v1/workspaces/list")
    end

    def create(email, name)
      params = {
          email: email,
          anonymousDataCollection: false,
          name: name,
          news: false,
          securityUpdates: false,
      }
      handle_request("/api/v1/workspaces/create", body: params)
    end

    def delete(workspace_id)
      params = {
        "workspaceId": workspace_id
      }
      handle_request("/api/v1/workspaces/delete", body: params)
    end
  end 
end