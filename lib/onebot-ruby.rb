require 'faye/websocket'
require 'json'
require 'event_emitter'
require 'net/http'
require 'logger'

class Hash
  def method_missing(m, *a)
    if m.to_s =~ /=$/
      self[Regexp.last_match.pre_match] = a[0]
    elsif a.empty?
      self[m]
    else
      super
    end
  end

  def respond_to_missing?(m, include_private = false)
    super unless m.to_s =~ /=$/
  end
end

# 一个基于 OneBot 标准的 QQ 机器人框架
module Onebot
  module Logging
    autoload :Logger, File.expand_path('Core/Logging/Logger', __dir__)
    autoload :EventLogger, File.expand_path('Core/Logging/EventLogger', __dir__)
  end

  module WebSocket
    autoload :Session, File.expand_path('Core/Websocket/Session', __dir__)
    autoload :API, File.expand_path('Core/Websocket/API', __dir__)
    autoload :Bot, File.expand_path('Core/Websocket/Bot', __dir__)
    autoload :Client, File.expand_path('Core/Websocket/Client', __dir__)
    autoload :Server, File.expand_path('Core/Websocket/Server', __dir__)
  end

  module Http
    autoload :API, File.expand_path('Core/Http/API', __dir__)
  end

  autoload :Core, File.expand_path('Core/Core', __dir__)
  autoload :Utils, File.expand_path('Core/Utils', __dir__)
end
