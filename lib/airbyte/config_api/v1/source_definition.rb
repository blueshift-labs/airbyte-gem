
module Airbyte
  def self.source_definition; SourceDefinition.new; end
  class SourceDefinition < ConfigAPIClient
    def list()
      handle_request("#{PATH_PREFIX_SOURCE_DEFINITIONS}/list")
    end

    def get_id(source_name)
      find_in_definitions(source_name, list())
    end

    def list_for_workspace(workspace_id)
      params = {
        workspaceId: workspace_id
      }
      handle_request("#{PATH_PREFIX_SOURCE_DEFINITIONS}/list_for_workspace", body: params)
    end

    def get_id_for_workspace(source_name, workspace_id)
      find_in_definitions(source_name, list_for_workspace(workspace_id))
    end

    def add_custom_definition_for_workspace(workspace_id, definition_info)
      params = {
        workspaceId: workspace_id,
        scopeType: definition_info[:scope_type],
        sourceDefinition: {
          name: definition_info[:source_name],
          dockerRepository: definition_info[:docker_repository],
          dockerImageTag: definition_info[:docker_image_tag],
          documentationUrl: definition_info[:documentation_url]
          }
      }
      handle_request("#{PATH_PREFIX_SOURCE_DEFINITIONS}/create_custom", body: params)
    end

    private def find_in_definitions(source_name, resp)
      list = resp['sourceDefinitions']
      id = nil
      list.find do |item|
        if item['name'] == source_name
            id = item['sourceDefinitionId']
            break
        end
      end
      id
    end
  end 
end