# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = 'ActionController::API'
 # config.lograge.formatter = Lograge::Formatters::Logstash.new # Lograge::Formatters::Json.new
  config.lograge.formatter =  Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      message: "from lograge",
      exception: event.payload[:exception], # ["ExceptionClass", "the message"]
      exception_object: event.payload[:exception_object] # the exception instance
    }
  end
end
