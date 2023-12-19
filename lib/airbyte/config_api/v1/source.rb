
module Airbyte
  def self.source; Source.new; end
  class Source < ConfigAPIClient
    def create(params)
      handle_request("#{PATH_PREFIX_SOURCES}/create", body: params)
    end

    def update(params)
      handle_request("#{PATH_PREFIX_SOURCES}/update", body: params)
    end

    def list(params)
      params = {
        workspaceIds: params[:workspace_ids],
        includeDeleted: params[:include_deleted],
        pagination: {
          pageSize: params[:page_size],
          rowOffset: params[:row_offset]
        },
        nameContains: params[:name_contains]
      }
      handle_request("#{PATH_PREFIX_SOURCES}/list_paginated", body: params)
    end

    def get(source_id)
      params = {
        sourceId: source_id
      }
      handle_request("#{PATH_PREFIX_SOURCES}/get", body: params)
    end

    def delete(source_id)
      params = {
        sourceId: source_id
      }
      handle_request("#{PATH_PREFIX_SOURCES}/delete", body: params)
    end

    def discover_schema(source_id, disable_cache = true)
      params = {
        sourceId: source_id,
        disable_cache: disable_cache
      }
      handle_request("#{PATH_PREFIX_SOURCES}/discover_schema", body: params)
    end

    def get_definition_id(source_name)
      Airbyte.source_definition.get_id(source_name)
    end

    def get_definition_for_workspace(source_name, workspace_id)
      Airbyte.source_definitions.get_id_for_workspace(source_name, workspace_id)
    end

    def validate_config(definition_id, workspace_id, connection_config)
      Airbyte.scheduler.validate_source_config(definition_id, workspace_id, connection_config)
    end
  end 
end