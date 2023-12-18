
module Airbyte
  module V1
    def self.source; Sources.new; end
    class Sources < APIClient
      def create(params)
        handle_request(RESOURCE_PATH_SOURCES, http_verb: :post, body: params)
      end

      def list(params)
        handle_request(RESOURCE_PATH_SOURCES, http_verb: :get, params: params)
      end

      def get(source_id)
        handle_request("#{RESOURCE_PATH_SOURCES}/#{source_id}", http_verb: :get)
      end

      def update(params)
        handle_request(RESOURCE_PATH_SOURCES, http_verb: :put, body: params)
      end

      def delete(source_id)
        handle_request("#{RESOURCE_PATH_SOURCES}/#{source_id}", http_verb: :delete)
      end

      def discover_schema(source_id, disable_cache = true)
        Airbyte.source.discover_schema(source_id, disable_cache)
      end

      def get_definition_id(source_name)
        Airbyte.source_definitions.get_id(source_name)
      end

      def validate_config(definition_id, connection_config)
        Airbyte.scheduler.validate_source_config(definition_id, connection_config)
      end
    end    
  end
end