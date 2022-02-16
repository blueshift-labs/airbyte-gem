$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require_relative './lib/airbyte.rb'
# require "airbyte"
# Airbyte.conn "http://localhost:8086"

Airbyte.configure do |config|
  config.url = "http://localhost:8000"
end

# 1. Create Workspace
# workspace = Airbyte.workspace.create("newtest@gmail.com", "NewTest")

# 2. List Workspace
puts Airbyte.workspace.list

# #puts workspace['workspaceId']
workspace_id = "82ecf7af-d0c6-4c47-b9e3-0f9040474611"

# 3.Get List of Source Definitions
resp = Airbyte.source_definition.list_latest(workspace_id)
list = resp['sourceDefinitions']
snowflake_source_def_id = nil
snowflake = "Snowflake"
list.each do |item|
    if item['name'] == snowflake
        snowflake_source_def_id = item['sourceDefinitionId']
    end
end
puts snowflake_source_def_id


# 4. Get the source definition specification 
# We already know the structure of data that need for source.TODO:: Write tests to check if the structure changes

# 5. Create a source as per specification
connection_config = {
  role:"SYSADMIN",
  warehouse:"COMPUTE_WH",
  database:"BLUESHIFT",
  schema:"ZUMPER",
  password:"H6\\jVWp^f?b&99X8",#H6\jVWp^f?b&99X8
  username:"blueshift2",
  host:"wk08061.snowflakecomputing.com"
}
source_config = {
  sourceDefinitionId:snowflake_source_def_id,
  connectionConfiguration: connection_config
}
resp = Airbyte.scheduler.validate_source_config(source_config)
if resp['status'] != 'succeeded'
    puts resp['message']
    exit
end


source_params = {
    name:"snowflake_via gem",
    sourceDefinitionId: snowflake_source_def_id,
    workspaceId: workspace_id,
    connectionConfiguration: connection_config
}
#resp = Airbyte.source.create(source_params)
#puts resp
source_id = "ac1c93b5-d521-4586-8c25-fe4b6eb02c7b"# resp['sourceId']

# 6 . Get List of Destination Definitions
resp = Airbyte.destination_definition.list_latest(workspace_id)
list = resp['destinationDefinitions']
s3_destination_def_id = nil
s3 = "S3"
list.each do |item|
    if item['name'] == s3
        s3_destination_def_id = item['destinationDefinitionId']
    end
end
puts s3_destination_def_id


# 7. Get the destination definition specification
# 8. Create a detination as per specification

destination_connection_config = {
    format:{
        flattening: "Root level flattening",
        format_type: "CSV",
        part_size_mb: 15
    },
    
    secret_access_key: "yzxSCt76WglX3Ywa8wU+lxdcr5SntEbkUG6Lr0bu",
    access_key_id: "AKIATQTVE6IEPCZPL2XT",
    s3_bucket_region: "us-west-2",
    s3_bucket_path: "snowflake/bsft",
    s3_bucket_name: "bsft-de-airbyte-testing",
    s3_endpoint: ""
}
destination_config = {
    destinationDefinitionId: s3_destination_def_id,
    connectionConfiguration: destination_connection_config
}
puts "validate s3 config"
resp = Airbyte.scheduler.validate_destination_config(destination_config)
puts resp['status']
if resp['status'] != 'succeeded'
    puts resp['message']
    exit
end
destination_params = {
    name:"s3_via_gem",
    destinationDefinitionId: s3_destination_def_id,
    workspaceId: workspace_id,
    connectionConfiguration: destination_connection_config
}
# resp = Airbyte.destination.create(destination_params)
# puts resp
puts "destination added"
destination_id = "1bebb54d-ec7a-4d65-9150-b357740dd688" #resp['destinationId'] #"destinationId"=>"90eeca59-c397-4242-b32c-a0b5da5e96eb"

# 9. Create a connection
# Get source specification schema. 
# Pass required schema while creating a connection.
sync_mode = "incremental"
connection_params = {
    sourceId: source_id,
    destinationId: destination_id,
    syncCatalog: {
      streams: [
        {
          config: {
            syncMode: sync_mode,
            cursorField: ["SITE"],
            destinationSyncMode: "append",
            primaryKey: [],
            aliasName: "ACCOUNT_INFO",
            selected: true
          },
          stream: {
            name: "ACCOUNT_INFO",
            jsonSchema: {
              type: "object",
              properties: {
                SITE: {
                  type: "string"
                },
                UUID: {
                  type: "string"
                },
                TIMEZONE: {
                  type: "string"
                }
              }
            },
            supportedSyncModes: [
              "full_refresh",
              "incremental"
            ],
            sourceDefinedCursor: nil,
            defaultCursorField: [],
            sourceDefinedPrimaryKey: [],
            namespace: "DELIVERABILITY_DASHBOARD"
          },
        },
        
      ]
    },
    prefix: "",
    namespaceDefinition: "source",
    namespaceFormat: "${SOURCE_NAMESPACE}",
    schedule: {
      units: 30,
      timeUnit: "minutes"
    },
    status: "inactive"
  }
puts connection_params
resp = Airbyte.connection.create(connection_params)
puts resp