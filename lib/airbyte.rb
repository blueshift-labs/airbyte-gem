# frozen_string_literal: true

require_relative "airbyte/version"

require "faraday"
require 'ostruct'
require 'typhoeus'
require 'connection_pool'
module Airbyte
  class Error < StandardError; end  

  def self.configuration
    @configuration ||= OpenStruct.new
  end
  def self.options
    @options
  end

  def self.connection_config_api
    @connection_config_api
  end

  def self.connection_airbyte_api
    @connection_airbyte_api
  end

  class Config < OpenStruct
  end

  def self.configure(&blk)
    @configuration = Airbyte::Config.new

    yield(configuration)
    @connection_config_api = ConnectionPool::Wrapper.new(size: @configuration.pool || 32, timeout: @configuration.timeout || 10) do
      connection = Faraday.new(:url => @configuration.host + ":#{@configuration.port_config_api|| 80}") do |builder|
        if @configuration.log_faraday_responses
          builder.use Faraday::Response::Logger, @configuration.logger || :logger
        end
        builder.adapter :typhoeus
        builder.request :basic_auth, @configuration.user_name, @configuration.password
      end
      connection
    end
    @connection_airbyte_api = ConnectionPool::Wrapper.new(size: @configuration.pool || 32, timeout: @configuration.timeout || 10) do
      connection = Faraday.new(:url => @configuration.host + ":#{@configuration.port_airbyte_api|| 80}") do |builder|
      if @configuration.log_faraday_responses
        builder.use Faraday::Response::Logger, @configuration.logger || :logger
      end
      builder.adapter :typhoeus
      builder.request :basic_auth, @configuration.user_name, @configuration.password
      end
      connection
    end

    require "airbyte/base_client"
    require "airbyte/error"
    # Powered By Airbyte APIs V1
    require "airbyte/powered_by_api/api_client"
    require "airbyte/powered_by_api/v1/constants"
    require "airbyte/powered_by_api/v1/workspace"
    require "airbyte/powered_by_api/v1/source"
    require "airbyte/powered_by_api/v1/destination"
    require "airbyte/powered_by_api/v1/sync_connection"
    require "airbyte/powered_by_api/v1/stream"
    require "airbyte/powered_by_api/v1/job"

    # Airbyte Config APIs V1
    require "airbyte/config_api/config_api_client"
    require "airbyte/config_api/v1/constants"
    require "airbyte/config_api/v1/source_definition"
    require "airbyte/config_api/v1/destination_definition"
    require "airbyte/config_api/v1/job"
    require "airbyte/config_api/v1/scheduler"
    require "airbyte/config_api/v1/source"
    require "airbyte/config_api/v1/destination"
    require "airbyte/config_api/v1/workspace"
    require "airbyte/config_api/v1/sync_connection"
  end
end
