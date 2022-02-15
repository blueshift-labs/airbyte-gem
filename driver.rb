$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require_relative './lib/airbyte.rb'
# require "airbyte"
# Airbyte.conn "http://localhost:8086"

Airbyte.configure do |config|
  config.url = "http://localhost:8086"
end

puts Airbyte.workspace.list
# puts Airbyte.workspace.create("newtest@gmail.com", "NewTest")