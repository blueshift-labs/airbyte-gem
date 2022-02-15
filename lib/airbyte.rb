# frozen_string_literal: true

require_relative "airbyte/version"
require "airbyte/config"
require "airbyte/workspace"
require "faraday"
require 'ostruct'

module Airbyte
  class Error < StandardError; end
  # Your code goes here...
  def self.url
    @url
  end
  def self.conn
    @conn
  end
  def self.configuration
    @configuration ||= OpenStruct.new
  end
  
  def self.configure
    yield(configuration)
    @url = @configuration.url
    @conn = Faraday.new(url:@url, headers: {'Content-Type' => 'application/json'})

  end
end
