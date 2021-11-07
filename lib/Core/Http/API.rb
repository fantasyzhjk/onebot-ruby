module Onebot
  # OneBot标准API
  # [OneBot文档] (https://github.com/howmanybots/onebot)
  #
  # Example:
  #   Onebot::Api.getImage file
  module Http
    class API
      # @return [URI] HTTP API链接
      attr_accessor :apiUrl

      # (初始化) 设置API地址
      #
      # @param apiIp [String]
      # @param apiPort [Number]
      # @return [URI]
      def initialize(apiIp: "127.0.0.1", apiPort: 5700)
        @apiUrl = URI::HTTP.build(host: apiIp, port: apiPort)
        @logger = Logging::EventLogger.new()
      end

      def setLogger(logger)
        @logger = Logging::EventLogger.new(logger)
        self
      end

      # 设置群名
      #
      # @param group_id [Number]
      # @param group_name [String]
      # @param url [URI]
      # @return [Hash]
      def setGroupName(group_id, group_name, url = @apiUrl)
        url.path = "/set_group_name"
        ret = { group_id: group_id.to_i, group_name: group_name }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data["status"] == "ok"
          @logger.log "设置群头像成功"
        else
          @logger.log "设置群头像失败", Logger::WARN
        end
        return data["data"]
      end

      # 下载图片(未完成)
      #
      # @param file [String]
      # @param url [URI]
      # @return [Hash]
      def getImage(file, url = @apiUrl)
        url.path = "/get_image"
        ret = { file: file }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data["status"] == "ok"
          @logger.log "下载图片成功"
        else
          @logger.log "下载图片失败", Logger::WARN
        end
        return data["data"]
      end

      # 获取消息
      #
      # @param message_id [Number]
      # @param url [URI]
      # @return [Hash]
      def get_msg(message_id, url = @apiUrl)
        url.path = "/get_msg"
        ret = { message_id: message_id }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data["status"] == "ok"
          @logger.log "消息获取成功"
        else
          @logger.log "消息获取失败", Logger::WARN
        end
        return data["data"]
      end

      # 发送私聊消息
      #
      # @param msg [String]
      # @param user_id [Number]
      # @param url [URI]
      # @return [Hash]
      def sendPrivateMessage(msg, user_id, url = @apiUrl)
        url.path = "/send_private_msg"
        ret = { user_id: user_id, message: msg }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data["status"] == "ok"
          message_id = data["data"]["message_id"]
          @logger.log "发送至私聊 #{user_id} 的消息: #{msg} (#{message_id})"
        else
          @logger.log "发送消息失败", Logger::WARN
        end
        return data["data"]
      end

      # 发送群聊消息
      #
      # @param msg [String]
      # @param group_id [Number]
      # @param url [URI]
      # @return [Hash]
      def sendGroupMessage(msg, group_id, url = @apiUrl)
        url.path = "/send_group_msg"
        ret = { group_id: group_id, message: msg }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data["status"] == "ok"
          message_id = data["data"]["message_id"]
          @logger.log "发送至群 #{group_id} 的消息: #{msg} (#{message_id})"
        else
          @logger.log "发送消息失败", Logger::WARN
        end
        return data["data"]
      end

      # 接受好友邀请
      #
      # @param flag [String]
      # @param reason [String]
      # @param url [URI]
      # @return [Boolean]
      def acceptFriendRequest(flag, reason = nil, url = @apiUrl)
        url.path = "/set_friend_add_request"
        ret = { flag: flag, approve: true, remark: reason }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data["status"] == "ok"
          @logger.log "已通过好友请求"
          true
        else
          @logger.log "请求通过失败", Logger::WARN
          false
        end
      end

      # 拒绝好友邀请
      #
      # @param flag [String]
      # @param url [URI]
      # @return [Boolean]
      def refuseFriendRequest(flag, url = @apiUrl)
        url.path = "/set_friend_add_request"
        ret = { flag: flag, approve: false }.to_json
        user_id = JSON.parse(Utils.httpPost(url, ret))
        if data["status"] == "ok"
          @logger.log "已拒绝好友请求"
          true
        else
          @logger.log "请求拒绝失败", Logger::WARN
          false
        end
      end

      # 接受加群请求
      #
      # @param flag [String]
      # @param sub_type [String]
      # @param url [URI]
      # @return [Boolean]
      def acceptGroupRequest(flag, sub_type, url = @apiUrl)
        url.path = "/set_group_add_request"
        ret = { flag: flag, sub_type: sub_type, approve: true }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data["status"] == "ok"
          @logger.log "已通过加群请求"
          true
        else
          @logger.log "请求通过失败", Logger::WARN
          false
        end
      end

      # 拒绝加群请求
      #
      # @param flag [String]
      # @param sub_type [String]
      # @param reason [String]
      # @param url [URI]
      # @return [Boolean]
      def refuseGroupRequest(flag, sub_type, reason = nil, url = @apiUrl)
        url.path = "/set_group_add_request"
        ret = { flag: flag, sub_type: sub_type, approve: false, reason: reason }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data["status"] == "ok"
          @logger.log "已拒绝加群请求"
          true
        else
          @logger.log "请求拒绝失败", Logger::WARN
          false
        end
      end
    end
  end
end
