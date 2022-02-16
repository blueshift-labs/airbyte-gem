require "json"
module Airbyte
  def self.destination; Destination.new; end
  class Destination
    def create(params)
      response = Airbyte.conn.post do |req|
          req.url "/api/v1/destinations/create"
          req.body = params.to_json
      end
      puts response.status
      JSON.parse(response.body)
  end
  end 
end