$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require_relative './lib/airbyte.rb'
require "logger"
require "awesome_print"

Airbyte.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.host = "http://localhost"
  config.port = 8000
  config.pool = 5
  config.timeout = 3600
  config.log_faraday_responses = true
end

# Tests:

# 1. Create Workspace
# workspace = Airbyte.workspace.create("newtest1@gmail.com", "NewTest1")

# 2. List Workspace
puts Airbyte.workspace.list

# puts workspace['workspaceId']
# workspace_id = workspace['workspaceId']
workspace_id = "82ecf7af-d0c6-4c47-b9e3-0f9040474611"

# 3.Get List of Source Definitions
source_name = "Snowflake"
snowflake_source_def_id = Airbyte.source.get_definition_id(workspace_id,source_name)
puts snowflake_source_def_id


# 4. Get the source definition specification 
# We already know the structure of data that need for source.TODO:: Write tests to check if the structure changes

# 5. Create a source as per specification
source_connection_config = {
  role: 'SYSADMIN',
  warehouse: 'COMPUTE_WH',
  database: 'BLUESHIFT',
  schema: 'ZUMPER',
  password: 'H6\\jVWp^f?b&99X8',#H6\jVWp^f?b&99X8
  username: 'blueshift2',
  host: 'wk08061.snowflakecomputing.com',
}
# resp = Airbyte.source.validate_config(snowflake_source_def_id, source_connection_config)
# if resp['status'] != 'succeeded'
#     puts resp['message']
#     exit
# end

# source_params = {
#     name:"snowflake_via gem_2",
#     sourceDefinitionId: snowflake_source_def_id,
#     workspaceId: workspace_id,
#     connectionConfiguration: source_connection_config
# }
# resp = Airbyte.source.create(source_params)
# puts resp
puts "-- Created Source --"
source_id = "ac1c93b5-d521-4586-8c25-fe4b6eb02c7b"# resp['sourceId']

# 6 . Get List of Destination Definitions
# destination_name = "S3"
# s3_destination_def_id = Airbyte.destination.get_definition_id(workspace_id, destination_name)
# puts s3_destination_def_id

# # 7. Get the destination definition specification
# # 8. Create a detination as per specification

# destination_connection_config = {
#     format:{
#         flattening: "Root level flattening",
#         format_type: "CSV",
#         part_size_mb: 15
#     },
    
#     secret_access_key: "" #TODO: add secret access key
#     access_key_id: "" #TODO: add access key
#     s3_bucket_region: "us-west-2",
#     s3_bucket_path: "snowflake/bsft",
#     s3_bucket_name: "bsft-de-airbyte-testing",
#     s3_endpoint: ""
# }

# puts "validate destination config"
# resp = Airbyte.destination.validate_config(s3_destination_def_id, destination_connection_config)
# puts resp['status']
# if resp['status'] != 'succeeded'
#     puts resp['message']
#     exit
# end

# destination_params = {
#     name:"s3_via_gem1_1",
#     destinationDefinitionId: s3_destination_def_id,
#     workspaceId: workspace_id,
#     connectionConfiguration: destination_connection_config
# }
# resp = Airbyte.destination.create(destination_params)
# puts resp
puts "destination added"
destination_id = "1bebb54d-ec7a-4d65-9150-b357740dd688" #resp['destinationId'] #"destinationId"=>"90eeca59-c397-4242-b32c-a0b5da5e96eb"


# 9. Get source specification schema. 
# source_schema = Airbyte.source.discover_schema(source_id)
# streams = source_schema["catalog"]["streams"]
# stream = streams.find {|item| item["stream"]["name"].include?("ACCOUNT_INFO")}
# puts stream


# 10. Create a connection
# Pass required schema while creating a connection.
stream_name = "ACCOUNT_INFO"
cursor_field = "SITE"
sync_mode = "incremental"
connection_params = {
  source_id: source_id,
  destination_id: destination_id,
  stream_config:{
    name: stream_name,
    sync_mode: sync_mode,
    cursor_field: [cursor_field]
  },
  schedule:{
    duration: 30,
    unit: "minutes"
  },
  prefix: "",
  namespace_definition: "source",
  namespace_format: "${SOURCE_NAMESPACE}",
  status: "inactive"
}

resp = Airbyte.sync_connection.create(connection_params)
puts "created conn"
ap resp
# Update the connection
connection_params[:status] = "active"
connection_params[:connection_id] = resp["connectionId"]
connection_params = {
  source_id: source_id,
  connection_id: resp["connectionId"],
  stream_config:{
    name: stream_name,
    sync_mode: sync_mode,
    cursor_field: [cursor_field]
  },
  schedule:{
    duration: 30,
    unit: "minutes"
  },
  prefix: "",
  namespace_definition: "source",
  namespace_format: "${SOURCE_NAMESPACE}",
  status: "active"
}
resp = Airbyte.sync_connection.update(connection_params)
puts "updated connection"
ap resp
# Delete the connection
# connection_id = "d4efca91-f659-4bd3-8ed5-865660c7e52e"
# resp = Airbyte.sync_connection.delete(connection_id)
