require 'faye/websocket'
require 'eventmachine'
require 'json'
require 'event_emitter'

module CQHttp
  autoload :Api, File.expand_path('Bot/Api', __dir__)
  autoload :Bot, File.expand_path('Bot/Bot', __dir__)
end


CQHttp::Bot.connect "ws//localhost:6700" do |ws|
  ws.on :close do
    puts 1
  end
end