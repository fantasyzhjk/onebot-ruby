module CQHttp
  class Api
    attr_accessor :apiUrl

    @apiUrl = 'http://127.0.0.1:5700'
    class << self
      def sendPrivateMessage(msg, user_id, url=@apiUrl)
        ret = { user_id: user_id, message: msg }.to_json
        message_id = JSON.parse(Utils.httpPost("#{url}/send_private_msg", ret))['data']['message_id']
        Utils.log Time.new, '↑', "发送至私聊 #{user_id} 的消息: #{msg} (#{message_id})"
        message_id
      end

      def sendGroupMessage(msg, group_id, url=@apiUrl)
        ret = { group_id: group_id, message: msg }.to_json
        message_id = JSON.parse(Utils.httpPost("#{url}/send_group_msg", ret))['data']['message_id']
        Utils.log Time.new, '↑', "发送至群 #{group_id} 的消息: #{msg} (#{message_id})"
        message_id
      end

      def acceptFriendRequest(flag, url=@apiUrl)
        ret = { flag: flag, approve: true }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/set_friend_add_request", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '已通过好友请求'
        else
          Utils.log Time.new, '!', '请求通过失败'
        end
      end

      def refuseFriendRequest(flag, url=@apiUrl)
        ret = { flag: flag, approve: false }.to_json
        user_id = JSON.parse(Utils.httpPost("#{url}/set_friend_add_request", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '已拒绝好友请求'
        else
          Utils.log Time.new, '!', '请求拒绝失败'
        end
      end

      def acceptGroupRequest(flag, sub_type, url=@apiUrl)
        ret = { flag: flag, sub_type: sub_type, approve: true }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/set_group_add_request", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '已通过加群请求'
        else
          Utils.log Time.new, '!', '请求通过失败'
        end
      end

      def refuseGroupRequest(flag, sub_type, url=@apiUrl)
        ret = { flag: flag, sub_type: sub_type, approve: false }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/set_group_add_request", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '已拒绝加群请求'
        else
          Utils.log Time.new, '!', '请求拒绝失败'
        end
      end
    end
  end
end
