
module Airbyte
  module V1
    def self.streams; Streams.new; end
    class Streams < APIClient

      def get(source_id, destination_id, ignore_cache = true)
        params = {
          sourceId: source_id,
          destinationId: destination_id,
          ignoreCache: ignore_cache
        }
        handle_request("#{RESOURCE_PATH_STREAMS}", http_verb: :get, params: params)
      end
    end    
  end
end