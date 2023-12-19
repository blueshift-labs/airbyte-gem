require 'json'
module Airbyte
  module V1
    def self.sync_connection; SyncConnection.new; end
    class SyncConnection < APIClient
      def build_connection_params(params)
        stream_list = Airbyte::V1.streams.get(params[:source_id], params[:destination_id])
        stream_config = params[:stream_config]
        stream = stream_list.find {|item| item["streamName"] == stream_config[:name]}
        error_body = {
            workspace_id: params[:workspace_id],
            source_id: params[:source_id],
            stream_name: stream_config[:name],
          }
        unless stream
          raise ObjectNotFoundError.new("Stream #{stream_config[:name]} Not Found in Source", STATUS_NOT_FOUND, JSON.load(error_body))
        end
        stream_params = {}
        stream_params[:name] = stream["streamName"]
        stream_params[:syncMode] = stream_config[:sync_mode]
        if stream_config[:sync_mode] == "incremental_append"
          is_cursor_field_present = stream["propertyFields"].any? { |arr| arr.include?(stream_config[:cursor_field]) }
          unless is_cursor_field_present
            error_body[:cursor_field] = stream_config[:cursor_field]
            raise ObjectNotFoundError.new("Cursor Field #{stream_config[:cursor_field]} Not Found in stream #{stream_config[:name]} of Source", STATUS_NOT_FOUND, JSON.load(error_body))
          end
          stream_params[:cursorField] = [stream_config[:cursor_field]]
        end
        connection_params = {
          name: params[:name],
          sourceId: params[:source_id],
          destinationId: params[:destination_id],
          workspaceId: params[:workspace_id],
          status: params[:status],
          schedule: {
              scheduleType: "manual"
          },
          dataResidency: params[:data_residency],
          nonBreakingSchemaUpdatesBehavior: params[:non_breaking_changes_preference],
          namespaceDefinition: params[:namespace_definition],
          namespaceFormat: params[:namespace_format],
          configurations: {
              streams: [
                  stream_params
              ]
          }
        }
        if params[:schedule_type] == "cron" 
          connection_params[:schedule][:cronExpression] = params[:cron_expression]
        end
        connection_params
      end

      def create(params)
        body = build_connection_params(params)
        handle_request(PATH_PREFIX_CONNECTIONS, http_verb: :post, body: body)
      end

      def update(params)
        body = build_connection_params(params)
        handle_request("#{PATH_PREFIX_CONNECTIONS}/#{params[:connection_id]}", http_verb: :patch, body: body)
      end

      def delete(connection_id)    
        handle_request("#{PATH_PREFIX_CONNECTIONS}/#{connection_id}", http_verb: :delete)
      end
    end 
  end
end