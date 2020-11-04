require 'faye/websocket'
require 'eventmachine'
require 'json'

module CQHttp
  autoload :Api, File.expand_path('Bot/Api', __dir__)
  autoload :Bot, File.expand_path('Bot/Bot', __dir__)
end
