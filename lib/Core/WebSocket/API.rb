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

        def get_msg(message_id, url = @apiUrl)
            echo = Time.now.to_i.to_s
            params = { action: "get_msg", params: { message_id: message_id }, echo: echo }.to_json
            @ws.send params
            @queueList[echo] = Queue.new
            ret = @queueList[echo].pop
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
        def sendPrivateMessage(msg, user_id)
          echo = Time.now.to_i.to_s
          params = { action: "send_private_msg", params: { user_id: user_id, message: msg }, echo: echo }.to_json
          @ws.send params
          @queueList[echo] = Queue.new
          ret = @queueList[echo].pop
          if parseRet(ret)
            @eventLogger.log "发送至私聊 #{user_id} 的消息: #{msg} (#{ret.data.message_id})"
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
        def sendGroupMessage(msg, group_id)
          echo = Time.now.to_i.to_s
          params = { action: "send_group_msg", params: { group_id: group_id, message: msg }, echo: echo }.to_json
          @ws.send params
          @queueList[echo] = Queue.new
          ret = @queueList[echo].pop
          @queueList.delete(echo)
          if parseRet(ret)
            @eventLogger.log "发送至群 #{group_id} 的消息: #{msg} (#{ret.data.message_id})"
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
          return true if ret.status == "ok"
          return false if ret.status == "failed"
        end
      end
    end
  end
  