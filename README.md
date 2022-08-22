# onebot-rb

[![Badge](https://img.shields.io/badge/OneBot-12-black)](https://onebot.dev/)
[![Gem Version](https://badge.fury.io/rb/ruby-cqhttp.svg)](https://badge.fury.io/rb/ruby-cqhttp)
[![yard docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/github/fantasyzhjk/ruby-cqhttp)

![图标](https://raw.githubusercontent.com/fantasyzhjk/ruby-cqhttp/main/icon.png)

一个基于 OneBot 标准的 QQ 机器人框架

用 Ruby 写 QQ 机器人！

本库还在快速迭代更新中。。(咕了

## 使用

安装

    $ gem install ruby-cqhttp

或者

在 `Gemfile` 中添加

```ruby
gem 'ruby-cqhttp'
```

然后运行

    $ bundle

## 示例

```ruby
require 'onebot-ruby'

logger = Onebot::Logging::Logger.new().setLoggerLevel(Logger::INFO) # 如果需要 logger 可以直接建立
api = Onebot::Http::API.new().setLogger(logger)

Onebot::Core.connect url: "ws://127.0.0.1:6700", logger: logger do |bot|
  bot.on :logged do |botQQ|
    logger.log('我开了欸')
  end

  bot.on :message do |data|
    logger.log('我收到消息了欸')
    # 复读
    bot.sendMessage(data.message, data)
  end

  # 获取并发出好友撤回的消息
  bot.on :notice do |notice_type, data|
    if notice_type == 'friend_recall'
      req = bot.get_msg(data.message_id)
      bot.sendPrivateMessage req.message, req.sender.user_id
    end
  end
  
  # 自动同意群邀请和好友请求
  bot.on :request do |request_type, data|
    if request_type == 'group'
      api.acceptGroupRequest(data.flag, data.sub_type) if data.sub_type == 'invite'
    elsif request_type == 'friend'
      api.acceptFriendRequest(data.flag)
    end
  end
end
```

**具体使用方法请查看 examples*
