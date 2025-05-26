require_relative '../lib/airbyte.rb'
require_relative 'spec_helper.rb'
require "logger"
require "awesome_print"
require "byebug"
describe 'Airbyte Powered By API' do
  current_datetime = "-Rspec:#{Time.now.strftime("%d-%m-%Y %H:%M")} "
  workspace_id = nil 
  source_id = nil 
  source_connection_config = nil
  destination_id = nil 
  destination_connection_config = nil
  connection_id = nil 
  job_id = nil
  stream_name = "customers"  # Table names are Case Insensitive in Databricks.
  cursor_field = "joined_at"

  after(:all) do
    # Clean up resources after all tests are done
    Airbyte::V1.sync_connection.delete(connection_id) unless connection_id.nil?
    Airbyte::V1.source.delete(source_id) unless source_id.nil?
    Airbyte::V1.destination.delete(destination_id) unless destination_id.nil?
    Airbyte::V1.workspace.delete(workspace_id) unless workspace_id.nil?
  end

  it '1. creates a workspace' do
    workspace = Airbyte::V1.workspace.create("Workspace SF Config API #{current_datetime}")
    expect(workspace).not_to be_nil
    expect(workspace['workspaceId']).not_to be_nil
    workspace_id = workspace['workspaceId']
  end

  it '2. Add databricks source definition to workspace' do
    definition_info = {
      scope_type: "workspace",
      source_name: "Databricks V1",
      docker_repository: "<aws_account_id>.dkr.ecr.<region>.amazonaws.com/airbyte/source-databricks",
      docker_image_tag: "v1",
      documentation_url: ""
    }
    resp = Airbyte::V1.source.add_custom_definition_for_workspace(workspace_id, definition_info)
    expect(resp).not_to be_nil
    expect(resp['sourceDefinitionId']).not_to be_nil
  end

  it '3. creates a source' do
    # Get List of Source Definitions
    source_name = "Databricks V1"
    databricks_source_def_id = Airbyte::V1.source.get_definition_for_workspace(source_name, workspace_id)
    expect(databricks_source_def_id).not_to be_nil
    # Get the source definition specification 
    # We already know the structure of data that need for source.TODO:: Write tests to check if the structure changes
    # Validate Source Config
    source_connection_config = {
      schema: "default",
      database: "main",
      databricks_port: "443",
      databricks_http_path: "/sql/1.0/warehouses/******",
      databricks_server_hostname: "dbc-****-**.cloud.databricks.com",
      databricks_personal_access_token: "******"
    }

    resp = Airbyte::V1.source.validate_config(databricks_source_def_id, workspace_id, source_connection_config)
    expect(resp).not_to be_nil
    if resp['status'] != 'succeeded'
        puts resp['message']
    end
    expect(resp['status']).to eq('succeeded')
    
    # Create Source
    source_params = {
        name: "databricks Powered By API - #{current_datetime} ",
        definition_id: databricks_source_def_id,
        workspace_id: workspace_id,
        configuration: source_connection_config
    }
    resp = {}
    expect{
      resp = Airbyte::V1.source.create(source_params)
    }.not_to raise_error
    expect(resp['sourceId']).not_to be_nil
    source_id = resp['sourceId']
  end

  it '3.1 updates source' do
    # update source
    source_params = {
        source_id: source_id,
        configuration: source_connection_config
    }
    resp = {}
    expect{
      resp = Airbyte::V1.source.update(source_params)
    }.not_to raise_error
    expect(resp['sourceId']).not_to be_nil
  end

  it '4. creates a destination' do
    # # 6 . Get List of Destination Definitions
    destination_name = "S3"
    s3_destination_def_id = Airbyte::V1.destination.get_definition_id(destination_name)
    expect(s3_destination_def_id).not_to be_nil

    # 7. Get the destination definition specification, we know the specification
    # 8. Create a detination as per specification
    destination_connection_config = {
      destinationType: "s3",
      format: {
          flattening: "No flattening",
          compression: {
              compression_type: "GZIP"
          },
          format_type: "JSONL"
      },
      access_key_id: "",
      s3_bucket_name: "",
      s3_bucket_path: "ameya.com/databricks",
      s3_bucket_region: "",
      secret_access_key: ""
    }

    puts "validate destination config"
    resp = {}
    expect { 
      resp = Airbyte::V1.destination.validate_config(s3_destination_def_id,workspace_id, destination_connection_config) 
    }.not_to raise_error
    expect(resp).not_to be_nil
    if resp['status'] != 'succeeded'
        puts resp['message']
    end
    expect(resp['status']).to eq('succeeded')

    destination_params = {
      name: "S3_powered_by_API_#{current_datetime}",
      workspace_id: workspace_id,
      definition_Id: s3_destination_def_id,
      configuration: destination_connection_config
    }
    resp = Airbyte::V1.destination.create(destination_params)
    expect(resp).not_to be_nil
    expect(resp['destinationId']).not_to be_nil

    destination_id = resp['destinationId']
  end

  it '4.1 updates destination' do
    # update destination
    destination_params = {
      destination_id: destination_id,
      configuration: destination_connection_config
    }
    resp = Airbyte::V1.destination.update(destination_params)
    expect(resp).not_to be_nil
    expect(resp['destinationId']).not_to be_nil
  end

  it '5. find table/view/stream in given source' do
    source_schema = Airbyte::V1.source.discover_schema(source_id)
    expect(source_schema).not_to be_nil
    streams = source_schema["catalog"]["streams"]
    expect(streams).not_to be_nil
    stream_info = streams.find {|item| item["stream"]["name"].include?(stream_name)}
    expect(stream_info).not_to be_nil
  end
  
  it '6. creates a connection' do
    stream_name = "customers"
    cursor_field = "joined_at"
    sync_mode = "incremental_append"

    connection_params = {
      source_id: source_id,
      stream_config: {
        name: stream_name,
        sync_mode: sync_mode,
        cursor_field: cursor_field
      },
      name: "Databricks - S3 - #{current_datetime}",
      destination_id: destination_id,
      workspace_id: workspace_id,
      status: "inactive",
      data_residency: "auto",
      non_breaking_changes_preference: "propagate_fully",
      namespace_definition: "custom_format",
      namespace_format: "customers/databricks_connector/jsonl",
      schedule_type: "manual", # or "cron" if using cron schedule
      cron_expression: "* * * * *" # if schedule_type is "cron"
    }
    
    resp = Airbyte::V1.sync_connection.create(connection_params)
    expect(resp).not_to be_nil
    expect(resp['connectionId']).not_to be_nil

    ap "Created conn: #{resp}"
    connection_id = resp['connectionId']
    ap "Connection Id #{connection_id}"    
  end

  it '7. Updates a connection' do
    stream_name = "customers"
    cursor_field = "joined_at"
    sync_mode = "incremental_append"

    connection_params = {
      connection_id: connection_id,
      source_id: source_id,
      stream_config: {
        name: stream_name,
        sync_mode: sync_mode,
        cursor_field: cursor_field
      },
      name: "Databricks - S3 - #{current_datetime}",
      destination_id: destination_id,
      workspace_id: workspace_id,
      status: "active", # Updated Field
      data_residency: "auto",
      non_breaking_changes_preference: "propagate_fully",
      namespace_definition: "custom_format",
      namespace_format: "customers/databricks_connector/jsonl",
      schedule_type: "manual", # or "cron" if using cron schedule
      cron_expression: "* * * * *" # if schedule_type is "cron"
    }
    resp = Airbyte::V1.sync_connection.update(connection_params)
    expect(resp).not_to be_nil
    expect(resp['connectionId']).not_to be_nil
    expect(resp['connectionId']).to eq(connection_id)
    ap "Updated conn: #{resp}"
  end

  it '8. triggers sync' do
    resp = Airbyte::V1.job.trigger_sync(connection_id)
    expect(resp).not_to be_nil
    expect(resp['jobId']).not_to be_nil
    job_id = resp['jobId']
    ap resp
  end

  it '9. checks sync status' do
    resp = Airbyte::V1.job.get_job_state(job_id)
    ap resp
    expect(resp['error_details']).to eq({})
    expect(resp['status']).not_to be_nil
  end
end
