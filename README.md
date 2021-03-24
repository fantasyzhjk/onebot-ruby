# RUBY-CQHTTP

[![Gem Version](https://badge.fury.io/rb/ruby-cqhttp.svg)](https://badge.fury.io/rb/ruby-cqhttp)
[![yard docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/gems/ruby-cqhttp)

一个基于 OneBot 标准的 QQ 机器人框架

用 Ruby 写 QQ 机器人！

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
require 'ruby-cqhttp'

CQHttp::Bot.connect host: '127.0.0.1', port: 6700 do |bot|
  bot.on :logged do |botQQ|
    CQHttp::Utils.log('我开了欸')
  end

  bot.on :message do |msg, sdr, tar|
    CQHttp::Utils.log('我收到消息了欸')
  end

  # 获取并发出好友撤回的消息
  bot.on :notice do |notice_type, data|
    if notice_type == 'friend_recall'
      req = CQHttp::Api.get_msg data['message_id']
      bot.sendPrivateMessage req['message'], req['sender']['user_id']
    end
  end
  
  # 自动同意群邀请和好友请求
  bot.on :request do |request_type, sub_type, flag|
    if request_type == 'group'
      CQHttp::Api.acceptGroupRequest(flag, sub_type) if sub_type == 'invite'
    elsif request_type == 'friend'
      CQHttp::Api.acceptFriendRequest(flag)
    end
  end
end
```
