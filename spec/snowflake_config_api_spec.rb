require_relative '../lib/airbyte.rb'
require_relative 'spec_helper.rb'
require "logger"
require "awesome_print"
require "byebug"

describe 'Airbyte API' do
  current_datetime = "-Rspec:#{Time.now.strftime("%d-%m-%Y %H:%M")} "
  workspace_id = nil 
  source_id = nil 
  destination_id = nil 
  connection_id = nil 
  job_id = nil
  stream_name = "CUSTOMERS"
  cursor_field = "joined_at"

  after(:all) do
    # Clean up resources after all tests are done
    Airbyte.sync_connection.delete(connection_id) unless connection_id.nil?
    Airbyte.source.delete(source_id) unless source_id.nil?
    Airbyte.destination.delete(destination_id) unless destination_id.nil?
    Airbyte.workspace.delete(workspace_id) unless workspace_id.nil?
  end

  it '1. creates a workspace' do
    workspace = Airbyte.workspace.create("newtest1@gmail.com", "Workspace SF Config API #{current_datetime}")
    expect(workspace).not_to be_nil
    expect(workspace['workspaceId']).not_to be_nil
    workspace_id = workspace['workspaceId']
  end

  it '2. creates a source' do
    # 3.Get List of Source Definitions
    source_name = "Snowflake"
    snowflake_source_def_id = Airbyte.source.get_definition_id(source_name)
    expect(snowflake_source_def_id).not_to be_nil
    # 4. Get the source definition specification 
    # We already know the structure of data that need for source.TODO:: Write tests to check if the structure changes
    # 5. Validate Source Config

    # *** Don't Git Push with Credentials ***
    # TODO: fetch from ENV or YML or some fixture and keep only placeholders here.
    source_connection_config = {
        credentials: {
          auth_type: "username/password",
          username: "*****", #TODO: fill correct username
          password: "*****" #TODO: fill correct password
      },
      warehouse: "<WH_NAME>",
      database: "<DB_NAME>",
      schema: "<SCHEMA_NAME",
      role: "***",
      host: "<HOST_URL>" 
    }
    resp = Airbyte.source.validate_config(snowflake_source_def_id, workspace_id, source_connection_config)
    expect(resp).not_to be_nil
    if resp['status'] != 'succeeded'
        puts resp['message']
    end
    expect(resp['status']).to eq('succeeded')
    
    # 5. Create Source
    source_params = {
        name: "Snowflake Config API - #{current_datetime} ",
        sourceDefinitionId: "#{snowflake_source_def_id}",
        workspaceId: workspace_id,
        connectionConfiguration: source_connection_config
    }
    
    expect{
      resp = Airbyte.source.create(source_params)
    }.not_to raise_error
    expect(resp['sourceId']).not_to be_nil
    source_id = resp['sourceId']
  end

  it '3. creates a destination' do
    # # 6 . Get List of Destination Definitions
    destination_name = "S3"
    s3_destination_def_id = Airbyte.destination.get_definition_id(destination_name)
    expect(s3_destination_def_id).not_to be_nil

    # 7. Get the destination definition specification
    # 8. Create a detination as per specification 
    ## Set AWS Credentials before running tests.  *** Don't Git Push with Credentials ***
    # TODO: fetch from ENV or YML or some fixture and keep only placeholders here.
    destination_connection_config = {
      access_key_id: "",
      s3_bucket_name: "",
      s3_bucket_path: "ameya.com/databricks",
      s3_bucket_region: "",
      secret_access_key: "",
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
    resp = {}
    expect { 
      resp = Airbyte.destination.validate_config(s3_destination_def_id,workspace_id, destination_connection_config) 
    }.not_to raise_error
    expect(resp).not_to be_nil
    if resp['status'] != 'succeeded'
        puts resp['message']
    end
    expect(resp['status']).to eq('succeeded')

    destination_params = {
        name:"S3_SF_config_API_#{current_datetime}",
        destinationDefinitionId: s3_destination_def_id,
        workspaceId: workspace_id,
        connectionConfiguration: destination_connection_config
    }
    resp = Airbyte.destination.create(destination_params)
    expect(resp).not_to be_nil
    expect(resp['destinationId']).not_to be_nil

    destination_id = resp['destinationId']
  end

  it '4. find table/view/stream in given source' do
    source_schema = Airbyte.source.discover_schema(source_id)
    expect(source_schema).not_to be_nil
    streams = source_schema["catalog"]["streams"]
    expect(streams).not_to be_nil
    stream_info = streams.find {|item| item["stream"]["name"].include?(stream_name)}
    expect(stream_info).not_to be_nil
  end
  
  it '5. creates a connection' do
    sync_mode = "incremental"
    destination_sync_mode = "append"
    nonBreakingChangesPreference = "propagate_fully"
    
    connection_params = {
      source_id: source_id,
      destination_id: destination_id,
      stream_config:{
        name: stream_name,
        sync_mode: sync_mode,
        cursor_field: [cursor_field],
        destination_sync_mode: destination_sync_mode
      },
      prefix: "",
      namespace_definition: "source",
      namespace_format: "${SOURCE_NAMESPACE}",
      status: "inactive",
      non_breaking_changes_preference: nonBreakingChangesPreference
    
    }
    
    resp = Airbyte.sync_connection.create(connection_params)
    expect(resp).not_to be_nil
    expect(resp['connectionId']).not_to be_nil

    ap "Created conn: #{resp}"
    connection_id = resp['connectionId']
    ap "Connection Id #{connection_id}"    
  end

  it '6. Updates a connection' do
    sync_mode = "incremental"
    destination_sync_mode = "append"
    nonBreakingChangesPreference = "propagate_fully"
    
    #updating following fields
    updated_namespace_definition = "customformat"
    updated_namespace_format = "customers/snowflake_connector/jsonl"
    updated_status = "active"

    connection_params = {
      connection_id: connection_id,
      source_id: source_id,
      destination_id: destination_id,
      stream_config:{
        name: stream_name,
        sync_mode: sync_mode,
        cursor_field: [cursor_field],
        destination_sync_mode: destination_sync_mode
      },
      prefix: "",
      namespace_definition: updated_namespace_definition,
      namespace_format: updated_namespace_format,
      status: updated_status,
      non_breaking_changes_preference: nonBreakingChangesPreference
    
    }
    resp = Airbyte.sync_connection.update(connection_params)
    expect(resp).not_to be_nil
    expect(resp['connectionId']).not_to be_nil
    expect(resp['connectionId']).to eq(connection_id)

    ap "Updated conn: #{resp}"
  end

  it '7. triggers sync' do
    resp = Airbyte.sync_connection.trigger_sync(connection_id)
    expect(resp).not_to be_nil
    expect(resp['job']['id']).not_to be_nil
    job_id = resp['job']['id']
    ap resp
  end

  it '8. checks sync status' do
    resp = Airbyte.job.get_job_state(job_id)
    ap resp
    expect(resp['error_details']).to eq({})
    expect(resp['status']).not_to be_nil
  end
end
