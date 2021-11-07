module Onebot
  # 消息处理，ws连接
  #
  # Example:
  #   Onebot::Core.connect host: host, port: port {|bot| ... }
  class Core
    # 新建连接
    #
    # @param host [String]
    # @param port [Number]
    # @return [WebSocket]
    def self.connect(url:, logger: nil)
      client = ::Onebot::WebSocket::Client.new(url: url, logger: logger)
      yield client if block_given?
      client.connect
      client
    end
  end
end
