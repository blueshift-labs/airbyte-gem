require "json"
module Airbyte
  def self.connection; Connection.new; end
  class Connection
    def create(params)
      response = Airbyte.conn.post do |req|
          req.url  "/api/v1/web_backend/connections/create"
          req.body = params.to_json
      end
      puts response.status
      JSON.parse(response.body)
  end
  end 
end