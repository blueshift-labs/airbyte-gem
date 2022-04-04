# frozen_string_literal: true

require_relative "airbyte/version"
require "airbyte/base_client"

require "airbyte/resources/workspace"
require "airbyte/resources/source_definition"
require "airbyte/resources/destination_definition"

require "airbyte/resources/scheduler"
require "airbyte/resources/source"
require "airbyte/resources/destination"
require "airbyte/resources/sync_connection"
require "faraday"
require 'ostruct'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'connection_pool'

module Airbyte
  class Error < StandardError; end
  # Your code goes here...
  # def self.url
  #   @url
  # end
  # def self.conn
  #   @conn
  # end
  
  def self.configuration
    @configuration ||= OpenStruct.new
  end
  def self.options
    @options
  end

  def self.connection
    @connection
  end
  class Config < OpenStruct
  end
  # def self.configure
  #   yield(configuration)
  #   @url = @configuration.url
  #   @conn = Faraday.new(url:@url, headers: {'Content-Type' => 'application/json'})

  # end
  def self.configure(&blk)
    @configuration = Airbyte::Config.new

    yield(configuration)
    puts @configuration.host 
    puts @configuration.port
    @connection = ConnectionPool::Wrapper.new(size: @configuration.pool || 32, timeout: @configuration.timeout || 10) do
      connection = Faraday.new(:url => @configuration.host + ":#{@configuration.port|| 80}") do |builder|
        if @configuration.log_faraday_responses
          #builder.adapter Faraday::Response::Logger, @configuration.logger || :logger
          builder.use Faraday::Response::Logger, @configuration.logger || :logger
        end
        # builder.adapter Faraday::Adapter::Typhoeus
        builder.use Faraday::Adapter::Typhoeus
        #builder.use FaradayMiddleware::ParseJson #cool for parsing response bodies
      end
      connection.path_prefix = ""
      puts connection
      connection
    end
  end
end
