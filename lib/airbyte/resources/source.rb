require "json"
module Airbyte
  def self.source; Source.new; end
  class Source
    def create(params)
      response = Airbyte.conn.post do |req|
          req.url "/api/v1/sources/create"
          req.body = params.to_json
      end
      JSON.parse(response.body)
    end
    def discover_schema(source_id)
      params = {
        sourceId: source_id
      }
      response = Airbyte.conn.post do |req|
          req.url "/api/v1/sources/discover_schema"
          req.body = params.to_json
      end
      JSON.parse(response.body)
    end
  end 
end