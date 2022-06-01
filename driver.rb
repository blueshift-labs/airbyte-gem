$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require_relative './lib/airbyte.rb'
require "logger"
require "awesome_print"
require "byebug"

Airbyte.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.host = "http://localhost"#"http://10.72.49.174"
  config.port = 8000
  config.pool = 5
  config.timeout = 3600
  config.log_faraday_responses = true
end

# Tests:

# 1. Create Workspace
# workspace = Airbyte.workspace.create("newtest1@gmail.com", "NewTest1")

# 2. List Workspace
# ap Airbyte.workspace.list

# puts workspace['workspaceId']
# workspace_id = workspace['workspaceId']
workspace_id = "9753d0b0-8b76-45e2-9359-e176100bb5f4"#"80f5a0d6-e4f4-47fd-9505-157c492b7a4a"

# 3.Get List of Source Definitions
source_name = "Snowflake"
snowflake_source_def_id = Airbyte.source.get_definition_id(source_name) #"e2d65910-8c8b-40a1-ae7d-ee2416b2bfa2"

puts snowflake_source_def_id
# 4. Get the source definition specification 
# We already know the structure of data that need for source.TODO:: Write tests to check if the structure changes

# 5. Create a source as per specification
source_connection_config = {
  credentials: {
    auth_type: "username/password",
    username: "sf_test_user1",
    password: "***" #TODO: fill correct password
},
warehouse: "COMPUTE_WH",
database: "DEMO1",
schema: "PUBLIC",
role: "SF_TEST1",
host: "qw03296.ap-south-1.snowflakecomputing.com"
}
# resp = Airbyte.source.validate_config(snowflake_source_def_id, source_connection_config)
# if resp['status'] != 'succeeded'
#     puts resp['message']
#     exit
# end
source_params = {
    name: "snowflake_direct3",
    sourceDefinitionId: "#{snowflake_source_def_id}1",
    workspaceId: workspace_id,
    connectionConfiguration: source_connection_config
}
begin
  resp = Airbyte.source.create(source_params)
rescue => exception
  puts exception
end
puts resp
# puts "-- Created Source --"
source_id = "b27e4842-9c67-433f-807c-8135fdade683"#resp['sourceId']

# 6 . Get List of Destination Definitions
destination_name = "S3"
s3_destination_def_id = "4816b78f-1489-44c1-9060-4b19d5fa9362"#Airbyte.destination.get_definition_id(destination_name)
# puts s3_destination_def_id

# # 7. Get the destination definition specification
# # 8. Create a detination as per specification
# byebug
destination_connection_config = {
  secret_access_key: "", #TODO: fill correct key
  s3_bucket_region: "us-west-2", #TODO: fill correct region
  s3_bucket_path: "abc.com/customers",
  s3_bucket_name: "bsft-customers-sandbox2",
  access_key_id: "", #TODO: fill correct key
  s3_endpoint: "",
  format: {
      part_size_mb: 5,
      format_type: "JSONL",
      compression: {
          compression_type: "GZIP"
      }
  }
}

# puts "validate destination config"
resp = Airbyte.destination.validate_config(s3_destination_def_id, destination_connection_config)
puts resp['status']
if resp['status'] != 'succeeded'
    puts resp['message']
    exit
end

destination_params = {
    name:"s3_via_gem1_3",
    destinationDefinitionId: s3_destination_def_id,
    workspaceId: workspace_id,
    connectionConfiguration: destination_connection_config
}
resp = Airbyte.destination.create(destination_params)
puts resp

puts "destination added"
destination_id = "fb7f4345-ae71-4985-bc67-0caa12e4f5d9"#resp['destinationId']#"1bebb54d-ec7a-4d65-9150-b357740dd688" #resp['destinationId'] #"destinationId"=>"90eeca59-c397-4242-b32c-a0b5da5e96eb"


# 9. Get source specification schema. 
# source_schema = Airbyte.source.discover_schema(source_id)
# streams = source_schema["catalog"]["streams"]
# stream = streams.find {|item| item["stream"]["name"].include?("ACCOUNT_INFO")}
# puts stream


# 10. Create a connection
# Pass required schema while creating a connection.
stream_name = "MEMBERS"
cursor_field = "FEE"
sync_mode = "incremental"
connection_params = {
  source_id: source_id,
  destination_id: destination_id,
  stream_config:{
    name: stream_name,
    sync_mode: sync_mode,
    cursor_field: [cursor_field]
  },
  prefix: "",
  namespace_definition: "source",
  namespace_format: "${SOURCE_NAMESPACE}",
  status: "active"
}

resp = Airbyte.sync_connection.create(connection_params)
puts "created conn"
# Update the connection
connection_params[:status] = "inactive"
connection_params[:connection_id] = resp["connectionId"]
connection_params = {
  source_id: source_id,
  connection_id: resp["connectionId"],
  stream_config:{
    name: stream_name,
    sync_mode: sync_mode,
    cursor_field: [cursor_field]
  },
  prefix: "",
  namespace_definition: "customformat",
  namespace_format: "customers/snowflake_connector/jsonl",
  status: "active"
}
resp = Airbyte.sync_connection.update(connection_params)
puts "updated connection"
ap resp
# Delete the connection
# connection_id = "d4efca91-f659-4bd3-8ed5-865660c7e52e"
# resp = Airbyte.sync_connection.delete(connection_id)

# connection_id = "8f86f4ce-556a-45a0-af8c-f3049cefb904"
# resp = Airbyte.sync_connection.trigger_sync(connection_id)
# puts resp