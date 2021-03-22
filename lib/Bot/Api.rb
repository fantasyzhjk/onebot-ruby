module CQHttp
  class Api
    attr_accessor :apiUrl
    class << self
      def setUrl(apiIp:'127.0.0.1', apiPort:5700)
        @apiUrl = URI::HTTP.build(host: apiIp, port: apiPort)
      end
      def setGroupName(group_id, group_name, url=@apiUrl)
        url.path = "/set_group_name"
        ret = { group_id: group_id.to_i, group_name: group_name }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data['status'] == 'ok'
          Utils.log '设置群头像成功'
        else
          Utils.log '设置群头像失败', Logger::WARN
        end
      end

      def getImage(file, url=@apiUrl)   # UNFINSHED
        url.path = "/get_image"
        ret = { file: file }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data['status'] == 'ok'
          Utils.log '下载图片成功'
          return data['data']
        else
          Utils.log '下载图片失败', Logger::WARN
        end
      end

      def get_msg(message_id, url=@apiUrl)   # UNFINSHED
        url.path = "/get_msg"
        ret = { message_id: message_id }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data['status'] == 'ok'
          Utils.log '消息获取成功'
          return data['data']
        else
          Utils.log '消息获取失败', Logger::WARN
        end
        
      end

      def sendPrivateMessage(msg, user_id, url=@apiUrl)
        url.path = "/send_private_msg"
        ret = { user_id: user_id, message: msg }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data['status'] == 'ok'
          message_id = data['data']['message_id']
          Utils.log "发送至私聊 #{user_id} 的消息: #{msg} (#{message_id})"
          return message_id
        else
          Utils.log '发送消息失败', Logger::WARN
        end
      end

      def sendGroupMessage(msg, group_id, url=@apiUrl)
        url.path = "/send_group_msg"
        ret = { group_id: group_id, message: msg }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data['status'] == 'ok'
          message_id = data['data']['message_id']
          Utils.log "发送至群 #{group_id} 的消息: #{msg} (#{message_id})"
          return message_id
        else
          Utils.log '发送消息失败', Logger::WARN
        end
      end

      def acceptFriendRequest(flag, url=@apiUrl)
        url.path = "/set_friend_add_request"
        ret = { flag: flag, approve: true }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data['status'] == 'ok'
          Utils.log '已通过好友请求'
        else
          Utils.log '请求通过失败', Logger::WARN
        end
      end

      def refuseFriendRequest(flag, url=@apiUrl)
        url.path = "/set_friend_add_request"
        ret = { flag: flag, approve: false }.to_json
        user_id = JSON.parse(Utils.httpPost(url, ret))
        if data['status'] == 'ok'
          Utils.log '已拒绝好友请求'
        else
          Utils.log '请求拒绝失败', Logger::WARN
        end
      end

      def acceptGroupRequest(flag, sub_type, url=@apiUrl)
        url.path = "/set_group_add_request"
        ret = { flag: flag, sub_type: sub_type, approve: true }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data['status'] == 'ok'
          Utils.log '已通过加群请求'
        else
          Utils.log '请求通过失败', Logger::WARN
        end
      end

      def refuseGroupRequest(flag, sub_type, url=@apiUrl)
        url.path = "/set_group_add_request"
        ret = { flag: flag, sub_type: sub_type, approve: false }.to_json
        data = JSON.parse(Utils.httpPost(url, ret))
        if data['status'] == 'ok'
          Utils.log '已拒绝加群请求'
        else
          Utils.log '请求拒绝失败', Logger::WARN
        end
      end
    end
  end
end
