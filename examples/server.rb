require '../lib/onebot-ruby'
require 'faye/websocket'
require 'rack'

logger = Onebot::Logging::Logger.new.setLoggerLevel(Logger::INFO)
static  = Rack::File.new(File.dirname(__FILE__))
options = { ping: 5 }

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    bot = Onebot::WebSocket::Server.new(env:, logger:, options:)

    bot.on :logged do |_botqq|
      logger.log('我开了欸')
    end

    bot.on :privateMessage do |data|
      # p data.message
      # p data
      p Onebot::Utils.cqParse(data.message) # 将 string 类型的消息解析成 array 类型
      bot.sendPrivateMessage(data.message, data.userId)
    end

    bot.rack_response
  else
    static.call(env)
  end
end

def App.log(message); end

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
