module Airbyte
  CONFIG_API_VERSION_V1 = "api/v1".freeze

  PATH_PREFIX_WORKSPACES = "/#{CONFIG_API_VERSION_V1}/workspaces".freeze
  PATH_PREFIX_SOURCES = "/#{CONFIG_API_VERSION_V1}/sources".freeze
  PATH_PREFIX_DESTINATIONS = "/#{CONFIG_API_VERSION_V1}/destinations".freeze
  PATH_PREFIX_BACKEND_CONNECTIONS = "/#{CONFIG_API_VERSION_V1}/web_backend/connections".freeze
  PATH_PREFIX_CONNECTIONS = "/#{CONFIG_API_VERSION_V1}/connections".freeze
  PATH_PREFIX_JOBS = "/#{CONFIG_API_VERSION_V1}/jobs".freeze
  PATH_PREFIX_DESTINATION_DEFINITIONS = "/#{CONFIG_API_VERSION_V1}/destination_definitions".freeze
  PATH_PREFIX_SOURCE_DEFINITIONS = "/#{CONFIG_API_VERSION_V1}/source_definitions".freeze
  PATH_PREFIX_SCHEDULER_SOURCE = "/#{CONFIG_API_VERSION_V1}/scheduler/sources".freeze
  PATH_PREFIX_SCHEDULER_DESTINATION = "/#{CONFIG_API_VERSION_V1}/scheduler/destinations".freeze
end
