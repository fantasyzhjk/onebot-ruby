module Onebot
  # WebSocket连接处理部分
  module WebSocket
    class API
      attr_accessor :queueList

      def initialize(ws, eventLogger)
        @ws = ws
        @eventLogger = eventLogger
        @queueList = {}
      end

      def get_msg(message_id, _url = @apiUrl)
        ret = send('get_msg', { message_id: })
        if parseRet(ret)
          @eventLogger.log "获取消息成功 (#{message_id})"
        else
          @eventLogger.log "获取消息失败，错误码: #{ret.msg}, 错误消息: #{ret.wording}", Logger::WARN
        end
        ret[:data]
      end

      # 发送私聊消息
      #
      # @param msg [String]
      # @param user_id [Number]
      # @return [Hash]
      def sendPrivateMessage(message, user_id)
        ret = send('send_private_msg', { user_id:, message: })
        if parseRet(ret)
          @eventLogger.log "发送至私聊 #{user_id} 的消息: #{message} (#{ret.data.message_id})"
        else
          @eventLogger.log "发送私聊消息失败，错误码: #{ret.msg}, 错误消息: #{ret.wording}", Logger::WARN
        end
        ret[:data]
      end

      # 发送群聊消息
      #
      # @param msg [String]
      # @param group_id [Number]
      # @return [Hash]
      def sendGroupMessage(message, group_id)
        ret = send('send_group_msg', { group_id:, message: })
        if parseRet(ret)
          @eventLogger.log "发送至群 #{group_id} 的消息: #{message} (#{ret.data.message_id})"
        else
          @eventLogger.log "发送群消息失败，错误码: #{ret.msg}, 错误消息: #{ret.wording}", Logger::WARN
        end
        ret[:data]
      end

      private

      #
      #  解析API返回
      #
      def parseRet(ret)
        return true if ret.status == 'ok'
        return false if ret.status == 'failed'
      end

      def send(action, params)
        echo = Time.now.to_i.to_s
        @ws.send({ action:, params:, echo: }.to_json)
        @queueList[echo] = Queue.new
        ret = @queueList[echo].pop
        @queueList.delete(echo)
        ret
      end
    end
  end
end
