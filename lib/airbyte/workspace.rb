require "faraday"
require "json"
module Airbyte
  def self.workspace; Workspace.new; end
  class Workspace
    def list
      response = Airbyte.conn.post "/api/v1/workspaces/list"
      JSON.parse(response.body)
    end

    def create(email, name)
      params = {
          email: email,
          anonymousDataCollection: false,
          name: name,
          news: false,
          securityUpdates: false,
      }
      response = Airbyte.conn.post do |req|
          req.url "/api/v1/workspaces/create"
          req.body = params.to_json
      end
      JSON.parse(response.body)
  end
  end 
end