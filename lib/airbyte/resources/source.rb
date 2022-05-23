
module Airbyte
  def self.source; Source.new; end
  class Source < BaseClient
    def create(params)
      handle_request("/api/v1/sources/create", body: params)
    end

    def update(params)
      handle_request("/api/v1/sources/update", body: params)
    end

    def discover_schema(source_id)
      params = {
        sourceId: source_id
      }
      handle_request("/api/v1/sources/discover_schema", body: params)
    end

    def get_definition_id(source_name)
      Airbyte.source_definition.get_id(source_name)
    end

    def validate_config(definition_id, connection_config)
      Airbyte.scheduler.validate_source_config(definition_id, connection_config)
    end
  end 
end