require 'onebot-ruby'

logger = Onebot::Logging::Logger.new.setLoggerLevel(Logger::INFO)
api = Onebot::Http::API.new(host: '127.0.0.1', port: 5700).setLogger(logger)

api.sendGroupMessage('Hello World', 123456789)

Onebot::Core.connect url: 'ws://127.0.0.1:6700', logger: logger, options: { headers: { 'Authorization' => 'Bearer xxxxxxxxxxxx' } } do |bot|
  bot.on :logged do |_botqq|
    logger.log('我开了欸')
  end

  # 事件 data 可参考 ↓
  # https://github.com/botuniverse/onebot-11/tree/master/event

  bot.on :message do |data|
    bot.sendMessage(data.message, data)
  end

  bot.on :groupMessage do |data|
    bot.sendGroupMessage(data.message, data.group_id)
  end

  bot.on :privateMessage do |data|
    bot.sendPrivateMessage(data.message, data.sender.user_id)
  end

  bot.on :notice do |notice_type, data|
    if notice_type == 'friend_recall'
      req = bot.get_msg(data.message_id)
      bot.sendPrivateMessage req.message, req.sender.user_id
    end
  end

  bot.on :request do |request_type, data|
    p request_type, data
  end
end
