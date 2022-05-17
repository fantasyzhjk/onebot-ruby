module Onebot
  # WebSocket连接处理部分
  module WebSocket
    class Server < Bot
      # @return [Faye::WebSocket] ws server
      attr_accessor :ws
      attr_accessor :api

      require 'rack'

      def initialize(env:, logger: nil, options: { ping: 5 }, &block)
        super
        @eventLogger = Logging::EventLogger.new(logger)
        @ws = Faye::WebSocket.new(env, %w[irc xmpp], options)
        @api = API.new(@ws, @eventLogger)
        @eventLogger.log(['客户端', '连接', @ws.url, @ws.version], ::Logger::INFO, 'Puma')

        @ws.on :message do |event|
          Thread.new { dataParse(event.data) }
        end

        @ws.on :close do |event|
          @eventLogger.log(['客户端', '断开', event.code].to_s, ::Logger::INFO, 'Puma')
          @ws = nil
        end

        yield self if block_given?
      end

      def rack_response
        @ws.rack_response
      end
    end
  end
end
