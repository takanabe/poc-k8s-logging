# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'logger'

# Put logs both file and stdout/stderr
# http://recipes.sinatrarb.com/p/middleware/rack_commonlogger
::Logger.class_eval { alias_method :write, :<< }
file = File.new('/var/log/sinatra.log', 'a+')
logger = ::Logger.new(file)

configure do
  use Rack::CommonLogger, logger
end

before do
  env['rack.errors'] = logger
  env['rack.logger'] = logger
end

get '/' do
  { log: 'Hello Sinatra app', stream: 'stdout' }.to_json
end

get '/error' do
  { log: 'Error on Sinatra app', stream: 'stderr' }.to_json
end
