module Onebot
  # WebSocket连接处理部分
  module WebSocket
    class Bot
      include EventEmitter
      # @return [Number] self QQ id
      attr_accessor :selfID

      def initialize(**args); end

      def method_missing(name, *args, &)
        return @api.send(name, *args, &) if !@api.nil? && @api.respond_to?(name)

        super
      end

      def respond_to_missing?(method_name, include_private = false)
        (!@api.nil? && @api.respond_to?(name)) || super
      end

      # 发送消息
      def sendMessage(msg, session)
        return sendGroupMessage msg, session.group_id if session.message_type == 'group'
        return sendPrivateMessage msg, session.user_id if session.message_type == 'private'
      end

      private

      #
      #  消息解析部分
      #
      def dataParse(data)
        msg = JSON.parse(data, symbolize_names: true)
        @eventLogger.dataParse(msg)
        # 连接成功
        if msg.meta_event_type == 'lifecycle' && msg.sub_type == 'connect'
          @selfID = msg.self_id
          emit :logged, @selfID
        end
        #
        # 函数回调
        #
        @api.queueList[msg.echo] << msg if msg.include?(:echo) # 往API模块回调返回消息
        case msg.post_type
        #
        # 请求事件
        #
        when 'request'
          emit :request, msg.request_type, msg
          #
          # 提醒事件
          #
        when 'notice'
          emit :notice, msg.notice_type, msg
          #
          # 消息事件
          #
        when 'message'
          if msg.message_type == 'group' # 判断是否为群聊
            emit :groupMessage, msg
          else
            emit :privateMessage, msg
          end
          emit :message, msg
        end
      end
    end
  end
end
