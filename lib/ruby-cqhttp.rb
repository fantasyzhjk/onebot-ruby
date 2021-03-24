require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'event_emitter'
require 'net/http'
require 'uri/ws'
require 'uri'
require 'logger'

# 一个基于 OneBot 标准的 QQ 机器人框架
module CQHttp
  autoload :Bot, File.expand_path('Bot/Bot', __dir__)
  autoload :Api, File.expand_path('Bot/Api', __dir__)
  autoload :Utils, File.expand_path('Bot/Utils', __dir__)
end

CQHttp::Utils.initLogger
