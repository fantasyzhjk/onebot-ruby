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
        ret = sendReq('get_msg', { message_id: })
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
        ret = sendReq('send_private_msg', { user_id:, message: })
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
        ret = sendReq('send_group_msg', { group_id:, message: })
        if parseRet(ret)
          @eventLogger.log "发送至群 #{group_id} 的消息: #{message} (#{ret.data.message_id})"
        else
          @eventLogger.log "发送群消息失败，错误码: #{ret.msg}, 错误消息: #{ret.wording}", Logger::WARN
        end
        ret[:data]
      end

      # 接受好友邀请
      #
      # @param flag [String]
      # @param reason [String]
      # @return [Boolean]
      def acceptFriendRequest(flag, reason = nil)
        data = sendReq('set_friend_add_request', { flag:, approve: true, remark: reason })
        if parseRet(data)
          @logger.log '已通过好友请求'
          true
        else
          @logger.log '请求通过失败', Logger::WARN
          false
        end
      end

      # 拒绝好友邀请
      #
      # @param flag [String]
      # @return [Boolean]
      def refuseFriendRequest(flag)
        data = sendReq('set_friend_add_request', { flag:, approve: false })
        if parseRet(data)
          @logger.log '已拒绝好友请求'
          true
        else
          @logger.log '请求拒绝失败', Logger::WARN
          false
        end
      end

      # 接受加群请求
      #
      # @param flag [String]
      # @param sub_type [String]
      # @return [Boolean]
      def acceptGroupRequest(flag, sub_type)
        data = sendReq('set_group_add_request', { flag:, sub_type:, approve: true })
        if parseRet(data)
          @logger.log '已通过加群请求'
          true
        else
          @logger.log '请求通过失败', Logger::WARN
          false
        end
      end

      # 拒绝加群请求
      #
      # @param flag [String]
      # @param sub_type [String]
      # @param reason [String]
      # @return [Boolean]
      def refuseGroupRequest(flag, sub_type, reason = nil)
        data = sendReq('set_group_add_request', { flag:, sub_type:, approve: false, reason: })
        if parseRet(data)
          @logger.log '已拒绝加群请求'
          true
        else
          @logger.log '请求拒绝失败', Logger::WARN
          false
        end
      end

      private

      #
      #  解析API返回
      #
      def parseRet(ret)
        return true if ret.status == 'ok'
        return false if ret.status == 'failed'
      end

      def sendReq(action, params)
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
