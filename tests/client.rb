require '../lib/onebot-ruby'

logger = Onebot::Logging::Logger.new.setLoggerLevel(Logger::INFO)
api = Onebot::Http::API.new.setLogger(logger)

Onebot::Core.connect url: 'ws://localhost:7700', logger: logger, options: { headers: { 'Authorization' => 'Bearer xxxxxxxxxxxx' } } do |bot|
  bot.on :logged do |_botqq|
    logger.log('我开了欸')
  end

  bot.on :privateMessage do |data|
    bot.sendMessage(session.message, data)
  end

  bot.on :notice do |notice_type, data|
    if notice_type == 'friend_recall'
      req = bot.get_msg(data.message_id)
      bot.sendPrivateMessage req.message, req.sender.user_id
    end
  end
end
