require File.expand_path('../app', __FILE__)

port   = ARGV[0] || 7000
secure = ARGV[1] == 'tls'
engine = ARGV[2] || 'thin'
spec   = File.expand_path(__dir__)

Faye::WebSocket.load_adapter(engine)

case engine

when 'goliath'
  class WebSocketServer < Goliath::API
    def response(env)
      App.call(env)
    end
  end

when 'puma'
  require 'puma/binder'
  require 'puma/events'
  events = Puma::Events.new($stdout, $stderr)
  binder = Puma::Binder.new(events)
  binder.parse(["tcp://0.0.0.0:#{port}"], App)
  server = Puma::Server.new(App, events)
  server.binder = binder
  server.run.join

when 'rainbows'
  rackup = Unicorn::Configurator::RACKUP
  rackup[:port] = port
  rackup[:set_listener] = true
  options = rackup[:options]
  options[:config_file] = File.expand_path('rainbows.conf', __dir__)
  Rainbows::HttpServer.new(App, options).start.join

when 'thin'
  thin = Rack::Handler.get('thin')
  thin.run(App, Host: '0.0.0.0', Port: port) do |server|
    if secure
      server.ssl_options = {
        private_key_file: spec + '/server.key',
        cert_chain_file: spec + '/server.crt'
      }
      server.ssl = true
    end
  end
end
