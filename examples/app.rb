require 'onebot-ruby'
require 'faye/websocket'
require 'rack'

logger = Onebot::Logging::Logger.new("./logs").setLoggerLevel(Logger::INFO)
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
      bot.sendPrivateMessage(data.message, data.user_id)
    end

    bot.rack_response
  else
    static.call(env)
  end
end

def App.log(message)
  logger.log(message, Logger::INFO, 'Server')
end
