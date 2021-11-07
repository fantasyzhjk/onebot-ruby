require "../lib/onebot-ruby"

logger = Onebot::Logging::Logger.new().setLoggerLevel(Logger::INFO)
api = Onebot::Http::API.new().setLogger(logger)

Onebot::WebSocket::Server.start port: 9000, logger: logger do |bot|
  bot.on :logged do |botQQ|
    logger.log("我开了欸")
  end

  bot.on :privateMessage do |session|
    # p session.message
    # p session
    bot.sendPrivateMessage(session.message, session.userId)
  end
end