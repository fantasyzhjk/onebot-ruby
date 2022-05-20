# ruby-cqhttp

![Badge](https://img.shields.io/badge/OneBot-11-black?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHAAAABwCAMAAADxPgR5AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAAxQTFRF////29vbr6+vAAAAk1hCcwAAAAR0Uk5T////AEAqqfQAAAKcSURBVHja7NrbctswDATQXfD//zlpO7FlmwAWIOnOtNaTM5JwDMa8E+PNFz7g3waJ24fviyDPgfhz8fHP39cBcBL9KoJbQUxjA2iYqHL3FAnvzhL4GtVNUcoSZe6eSHizBcK5LL7dBr2AUZlev1ARRHCljzRALIEog6H3U6bCIyqIZdAT0eBuJYaGiJaHSjmkYIZd+qSGWAQnIaz2OArVnX6vrItQvbhZJtVGB5qX9wKqCMkb9W7aexfCO/rwQRBzsDIsYx4AOz0nhAtWu7bqkEQBO0Pr+Ftjt5fFCUEbm0Sbgdu8WSgJ5NgH2iu46R/o1UcBXJsFusWF/QUaz3RwJMEgngfaGGdSxJkE/Yg4lOBryBiMwvAhZrVMUUvwqU7F05b5WLaUIN4M4hRocQQRnEedgsn7TZB3UCpRrIJwQfqvGwsg18EnI2uSVNC8t+0QmMXogvbPg/xk+Mnw/6kW/rraUlvqgmFreAA09xW5t0AFlHrQZ3CsgvZm0FbHNKyBmheBKIF2cCA8A600aHPmFtRB1XvMsJAiza7LpPog0UJwccKdzw8rdf8MyN2ePYF896LC5hTzdZqxb6VNXInaupARLDNBWgI8spq4T0Qb5H4vWfPmHo8OyB1ito+AysNNz0oglj1U955sjUN9d41LnrX2D/u7eRwxyOaOpfyevCWbTgDEoilsOnu7zsKhjRCsnD/QzhdkYLBLXjiK4f3UWmcx2M7PO21CKVTH84638NTplt6JIQH0ZwCNuiWAfvuLhdrcOYPVO9eW3A67l7hZtgaY9GZo9AFc6cryjoeFBIWeU+npnk/nLE0OxCHL1eQsc1IciehjpJv5mqCsjeopaH6r15/MrxNnVhu7tmcslay2gO2Z1QfcfX0JMACG41/u0RrI9QAAAABJRU5ErkJggg==)
[![Gem Version](https://badge.fury.io/rb/ruby-cqhttp.svg)](https://badge.fury.io/rb/ruby-cqhttp)
[![yard docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/gems/ruby-cqhttp/)

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

**具体使用方法请查看 tests*
