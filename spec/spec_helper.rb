# spec/spec_helper.rb

require_relative '../lib/airbyte.rb'

RSpec.configure do |config|
  config.before(:all) do
    Airbyte.configure do |config|
      config.logger = Logger.new(STDOUT)
      config.host = "http://localhost"
      config.port_config_api = 8000
      config.port_airbyte_api = 8006
      config.pool = 5
      config.timeout = 3600
      config.log_faraday_responses = true
      config.user_name = 'airbyte'
      config.password = '******'
    end
  end

  # Add an after(:all) hook if you need to perform any cleanup after all tests
end
