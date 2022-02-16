require "json"
module Airbyte
  def self.source; Source.new; end
  class Source
    def create(params)
      response = Airbyte.conn.post do |req|
          req.url "/api/v1/sources/create"
          req.body = params.to_json
      end
      puts response.status
      JSON.parse(response.body)
    end
  end 
end