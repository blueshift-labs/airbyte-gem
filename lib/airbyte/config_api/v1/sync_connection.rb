module Airbyte
  def self.sync_connection; SyncConnection.new; end
  class SyncConnection < ConfigAPIClient
    def build_payload(params)
      source_schema = Airbyte.source.discover_schema(params[:source_id])
      streams = source_schema["catalog"]["streams"]
      stream_config = params[:stream_config]
      stream_info = streams.find {|item| item["stream"]["name"] == stream_config[:name]}
      stream_info["config"]["syncMode"] = stream_config[:sync_mode]
      stream_info["config"]["destinationSyncMode"] = "append"
      stream_info["config"]["selected"] = true

      if stream_config[:sync_mode] == "incremental"
        stream_info["config"]["cursorField"] = stream_config[:cursor_field]
      end
      connection_params = {
        sourceId: params[:source_id],
        destinationId: params[:destination_id],
        syncCatalog: {
          streams: [
            {
              stream: stream_info["stream"],
              config: stream_info["config"]
            }
          ]
        },
        prefix: params[:prefix],
        namespaceDefinition: params[:namespace_definition],
        namespaceFormat: params[:namespace_format],
        status: params[:status],
        geography: params[:data_residency],
        nonBreakingChangesPreference: params[:non_breaking_changes_preference]
      }
      if params.key?(:schedule)
        connection_params[:schedule] = {
          units: params[:schedule][:duration],
          timeUnit: params[:schedule][:unit]
        }
      end
      connection_params
    end

    def create(params)    
      connection_params = build_payload(params)
      handle_request("web_backend/connections/create", body: connection_params)
    end

    def update(params)    
      connection_params = build_payload(params)
      connection_params[:connectionId] = params[:connection_id]
      handle_request("web_backend/connections/update", body: connection_params)
    end

    def trigger_sync(connection_id)    
      params = {connectionId: connection_id}
      handle_request("connections/sync", body: params)
    end

    def delete(connection_id)    
      params = {connectionId: connection_id}
      handle_request("connections/delete", body: params)
    end
  end 
end