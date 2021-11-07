require "../lib/onebot-ruby"

logger = Onebot::Logging::Logger.new().setLoggerLevel(Logger::INFO)
api = Onebot::Http::API.new().setLogger(logger)

Onebot::Core.connect url: "ws://tyun.fantasyzhjk.top:7700", logger: logger do |bot|
  bot.on :logged do |botQQ|
    logger.log("我开了欸")
  end

  bot.on :privateMessage do |session|
    bot.sendMessage(session.message, session)
  end

  bot.on :notice do |notice_type, data|
    if notice_type == 'friend_recall'
      req = bot.get_msg(data.message_id)
      bot.sendPrivateMessage req.message, req.sender.user_id
    end
  end
end