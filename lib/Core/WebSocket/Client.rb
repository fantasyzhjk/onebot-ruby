module Onebot
  # WebSocket连接处理部分
  module WebSocket
    class Client < Bot
      # @return [URI] WS URL
      attr_accessor :url
      # @return [Faye::WebSocket::Client] WS Conn
      attr_accessor :ws
      attr_accessor :api

      # 设置 WS URL
      def initialize(url: nil, logger: nil, **args)
        super
        @eventLogger = Logging::EventLogger.new(logger)
        @url = url
      end

      # 连接 WS
      def connect(protocols = nil, options = {})
        @eventLogger.log '正在连接到 ' << @url
        EM.run do
          @ws = Faye::WebSocket::Client.new(@url, protocols, options)
          @api = API.new(@ws, @eventLogger)

          @ws.on :message do |event|
            Thread.new { dataParse(event.data) }
          end

          @ws.on :close do |event|
            emit :close, event
            @eventLogger.log '连接断开'
            @ws = nil
            EM.stop
          end

          @ws.on :error do |event|
            emit :error, event
            @ws = nil
          end
        end
      end
    end
  end
end
