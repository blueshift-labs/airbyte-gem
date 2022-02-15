module Airbyte
  class Client 
    def self.execute_api_request(url, **args)
      response = @conn.post "/api/v1/workspaces/list"
      JSON.parse(response.body)
    end 
  end
end