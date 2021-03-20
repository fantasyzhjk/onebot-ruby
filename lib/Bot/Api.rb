module CQHttp
  class Api
    attr_accessor :apiUrl

    @apiUrl = 'http://127.0.0.1:5700'
    class << self
      def setGroupName(group_id, group_name, url=@apiUrl)
        ret = { group_id: group_id.to_i, group_name: group_name }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/set_group_name", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '设置群头像成功'
        else
          Utils.log Time.new, '×', '设置群头像失败'
        end
      end

      def getImage(file, url=@apiUrl)   # UNFINSHED
        ret = { file: file }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/get_image", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '下载图片成功'
          return data['data']
        else
          Utils.log Time.new, '×', '下载图片失败'
        end
      end

      def get_msg(message_id, url=@apiUrl)   # UNFINSHED
        ret = { message_id: message_id }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/get_msg", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '消息获取成功'
          return data['data']
        else
          Utils.log Time.new, '×', '消息获取失败'
        end
        
      end

      def sendPrivateMessage(msg, user_id, url=@apiUrl)
        ret = { user_id: user_id, message: msg }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/send_private_msg", ret))
        if data['status'] == 'ok'
          message_id = data['data']['message_id']
          Utils.log Time.new, '↑', "发送至私聊 #{user_id} 的消息: #{msg} (#{message_id})"
          return message_id
        else
          Utils.log Time.new, '×', '发送消息失败'
        end
      end

      def sendGroupMessage(msg, group_id, url=@apiUrl)
        ret = { group_id: group_id, message: msg }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/send_group_msg", ret))
        if data['status'] == 'ok'
          message_id = data['data']['message_id']
          Utils.log Time.new, '↑', "发送至群 #{group_id} 的消息: #{msg} (#{message_id})"
          return message_id
        else
          Utils.log Time.new, '×', '发送消息失败'
        end
      end

      def acceptFriendRequest(flag, url=@apiUrl)
        ret = { flag: flag, approve: true }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/set_friend_add_request", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '已通过好友请求'
        else
          Utils.log Time.new, '×', '请求通过失败'
        end
      end

      def refuseFriendRequest(flag, url=@apiUrl)
        ret = { flag: flag, approve: false }.to_json
        user_id = JSON.parse(Utils.httpPost("#{url}/set_friend_add_request", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '已拒绝好友请求'
        else
          Utils.log Time.new, '×', '请求拒绝失败'
        end
      end

      def acceptGroupRequest(flag, sub_type, url=@apiUrl)
        ret = { flag: flag, sub_type: sub_type, approve: true }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/set_group_add_request", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '已通过加群请求'
        else
          Utils.log Time.new, '×', '请求通过失败'
        end
      end

      def refuseGroupRequest(flag, sub_type, url=@apiUrl)
        ret = { flag: flag, sub_type: sub_type, approve: false }.to_json
        data = JSON.parse(Utils.httpPost("#{url}/set_group_add_request", ret))
        if data['status'] == 'ok'
          Utils.log Time.new, '√', '已拒绝加群请求'
        else
          Utils.log Time.new, '×', '请求拒绝失败'
        end
      end
    end
  end
end
