module Onebot
  # OneBot标准API
  # [OneBot文档] (https://github.com/howmanybots/onebot)
  #
  # Example:
  #   Onebot::Api.getImage file
  module Http
    class API
      # @return [URI] HTTP API链接
      attr_accessor :url

      # (初始化) 设置API地址
      #
      # @param host [String]
      # @param port [Number]
      # @return [URI]
      def initialize(host: '127.0.0.1', port: 5700)
        @url = URI::HTTP.build(host: host, port: port)
        @logger = Logging::EventLogger.new
      end

      def setLogger(logger)
        @logger = Logging::EventLogger.new(logger)
        self
      end

      # 设置群名
      #
      # @param group_id [Number]
      # @param group_name [String]
      # @return [Hash]
      def setGroupName(group_id, group_name)
        data = sendReq('set_group_name', { group_id: group_id.to_i, group_name: })
        if data['status'] == 'ok'
          @logger.log '设置群头像成功'
        else
          @logger.log '设置群头像失败', Logger::WARN
        end
        data['data']
      end

      # 获取图片信息
      #
      # @param file [String]
      # @return [Hash]
      def getImage(file)
        data = sendReq('get_image', { file: })
        if data['status'] == 'ok'
          @logger.log '下载图片成功'
        else
          @logger.log '下载图片失败', Logger::WARN
        end
        data['data']
      end

      # 获取消息
      #
      # @param message_id [Number]
      # @return [Hash]
      def get_msg(message_id)
        data = sendReq('get_msg', { message_id: })
        if data['status'] == 'ok'
          @logger.log '消息获取成功'
        else
          @logger.log '消息获取失败', Logger::WARN
        end
        data['data']
      end

      # 发送私聊消息
      #
      # @param msg [String]
      # @param user_id [Number]
      # @return [Hash]
      def sendPrivateMessage(msg, user_id)
        data = sendReq('send_private_msg', { user_id:, message: msg })
        if data['status'] == 'ok'
          message_id = data['data']['message_id']
          @logger.log "发送至私聊 #{user_id} 的消息: #{msg} (#{message_id})"
        else
          @logger.log '发送消息失败', Logger::WARN
        end
        data['data']
      end

      # 发送群聊消息
      #
      # @param msg [String]
      # @param group_id [Number]
      # @return [Hash]
      def sendGroupMessage(msg, group_id)
        data = sendReq('send_group_msg', { group_id:, message: msg })
        if data['status'] == 'ok'
          message_id = data['data']['message_id']
          @logger.log "发送至群 #{group_id} 的消息: #{msg} (#{message_id})"
        else
          @logger.log '发送消息失败', Logger::WARN
        end
        data['data']
      end

      # 接受好友邀请
      #
      # @param flag [String]
      # @param reason [String]
      # @return [Boolean]
      def acceptFriendRequest(flag, reason = nil)
        data = sendReq('set_friend_add_request', { flag:, approve: true, remark: reason })
        if data['status'] == 'ok'
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
        if data['status'] == 'ok'
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
        if data['status'] == 'ok'
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
        if data['status'] == 'ok'
          @logger.log '已拒绝加群请求'
          true
        else
          @logger.log '请求拒绝失败', Logger::WARN
          false
        end
      end

      private

      def sendReq(action, params, url = @url)
        url.path = '/' << action
        JSON.parse(Utils.httpPost(url, params.to_json))
      end
    end
  end
end
