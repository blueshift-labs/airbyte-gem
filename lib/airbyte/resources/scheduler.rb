require "faraday"
require "json"
module Airbyte
  def self.scheduler; Scheduler.new; end
  class Scheduler
    def validate_source_config(params)
      response = Airbyte.conn.post do |req|
          req.url "/api/v1/scheduler/sources/check_connection"
          req.body = params.to_json
      end
      puts response.status
      JSON.parse(response.body)
    end
    def validate_destination_config(params)
        response = Airbyte.conn.post do |req|
            req.url "/api/v1/scheduler/destinations/check_connection"
            req.body = params.to_json
        end
        puts response.status
        JSON.parse(response.body)
    end
  end 
end