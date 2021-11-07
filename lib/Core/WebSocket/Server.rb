module Onebot
  # WebSocket连接处理部分
  module WebSocket
    class Server < Bot
      # @return [Faye::WebSocket] ws server
      attr_accessor :ws
      attr_accessor :api

      require "rack"
      def self.websocket?(env)
        Faye::WebSocket.websocket?(env)
      end

      def initialize(env:, logger: nil, &block)
        super
        @eventLogger = Logging::EventLogger.new(logger)
        options = { :ping => 5 }
        @ws = Faye::WebSocket.new(env, ["irc", "xmpp"], options)
        @api = API.new(@ws, @eventLogger)
        @eventLogger.log(["客户端", "连接", @ws.url, @ws.version], ::Logger::INFO, "Puma")

        @ws.on :message do |event|
          Thread.new { dataParse(event.data) }
        end

        @ws.on :close do |event|
          @eventLogger.log(["客户端", "断开", event.code].to_s, ::Logger::INFO, "Puma")
          @ws = nil
        end

        @ws.rack_response

        yield self if block_given?
      end

      def self.start(port: 9000, logger: nil, &block)
        @port = port
        @@logger = logger
        @App = lambda do |env|
          if websocket?(env)
            Server.new(env: env, logger: logger, &block)
          else
            [200, { 'Content-Type' => 'text/plain' }, ['Hello']]
          end
        end
        def @App.log(message)
          if @@logger == nil
            puts message 
          else
            @@logger.log(message, ::Logger::INFO, "Puma")
          end
        end
        Faye::WebSocket.load_adapter("puma")
        @App.log("Starting Server")
        require "puma/binder"
        require "puma/events"
        events = Puma::Events.new($stdout, $stderr)
        binder = Puma::Binder.new(events)
        binder.parse(["tcp://0.0.0.0:#{@port}"], @App)
        server = Puma::Server.new(@App, events)
        server.binder = binder
        server.run.join
      end
    end
  end
end

