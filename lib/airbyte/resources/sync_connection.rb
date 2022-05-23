require 'json'
module Airbyte
  def self.sync_connection; SyncConnection.new; end
  class SyncConnection < BaseClient
    def create(params)    
      source_schema = Airbyte.source.discover_schema(params[:source_id])
      streams = source_schema["catalog"]["streams"]
      stream_config = params[:stream_config]
      stream = streams.find {|item| item["stream"]["name"] == stream_config[:name]}
      stream["config"]["syncMode"] = stream_config[:sync_mode]
      if stream_config[:sync_mode] == "incremental"
        stream["config"]["cursorField"] = stream_config[:cursor_field]
      end
      connection_params = {
        sourceId: params[:source_id],
        destinationId: params[:destination_id],
        syncCatalog: {
          streams: [
            stream,
          ]
        },
        prefix: params[:prefix],
        namespaceDefinition: params[:namespace_definition],
        namespaceFormat: params[:namespace_format],
        status: params[:status]
      }
      if params.key?(:schedule)
        connection_params[:schedule] = {
          units: params[:schedule][:duration],
          timeUnit: params[:schedule][:unit]
        }
      end
      handle_request("/api/v1/web_backend/connections/create", body: connection_params)
    end

    def update(params)    
      source_schema = Airbyte.source.discover_schema(params[:source_id])
      streams = source_schema["catalog"]["streams"]
      stream_config = params[:stream_config]
      stream = streams.find {|item| item["stream"]["name"] == stream_config[:name]}
      stream["config"]["syncMode"] = stream_config[:sync_mode]
      if stream_config[:sync_mode] == "incremental"
        stream["config"]["cursorField"] = stream_config[:cursor_field]
      end
      connection_params = {
        connectionId: params[:connection_id],
        syncCatalog: {
          streams: [
            stream,
          ]
        },
        prefix: params[:prefix],
        namespaceDefinition: params[:namespace_definition],
        namespaceFormat: params[:namespace_format],
        status: params[:status]
      }
      if params.key?(:schedule)
        connection_params[:schedule] = {
          units: params[:schedule][:duration],
          timeUnit: params[:schedule][:unit]
        }
      end
      handle_request("/api/v1/web_backend/connections/update", body: connection_params)
    end

    def trigger_sync(connection_id)    
      params = {connectionId: connection_id}
      handle_request("/api/v1/connections/sync", body: params)
    end

    def delete(connection_id)    
      params = {connectionId: connection_id}
      handle_request("/api/v1/connections/delete", body: params)
    end
  end 
end