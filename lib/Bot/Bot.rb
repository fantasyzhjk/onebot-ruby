module CQHttp
  # 消息处理，ws连接
  #
  # Example:
  #   CQHttp::Bot.connect host: host, port: port {|bot| ... }
  class Bot
    # 发送人信息
    # 
    # @!attribute age
    #    @return [Number] 年龄
    # @!attribute member_role
    #    @return [String] 角色，owner 或 admin 或 member
    # @!attribute card
    #    @return [String] 群名片／备注
    # @!attribute user_id
    #    @return [Number] 发送者 QQ 号
    # @!attribute qqlevel
    #    @return [String] 成员等级
    # @!attribute nickname
    #    @return [String] 昵称
    # @!attribute title
    #    @return [String] 专属头衔
    # @!attribute sex
    #    @return [String] 性别，male 或 female 或 unknown
    Sender = Struct.new(:age, :member_role, :card, :user_id, :qqlevel, :nickname, :title, :sex)
    # 消息事件数据
    #
    # @!attribute messagetype
    #   @return [String] 成员等级
    # @!attribute time
    #   @return [Number] 事件发生的时间戳
    # @!attribute group_id
    #   @return [Number] 群号
    # @!attribute user_id
    #   @return [Number] 发送者 QQ 号
    # @!attribute message_id
    #   @return [Number] 消息 ID
    # @!attribute message
    #   @return [String] 消息内容
    # @!attribute raw_message
    #   @return [String] 原始消息内容
    # @!attribute sub_type
    #   @return [String] 消息子类型，私聊中如果是好友则是 friend，如果是群临时会话则是 group，群聊中正常消息是 normal，匿名消息是 anonymous，系统提示（如「管理员已禁止群内匿名聊天」）是 notice
    # @!attribute anonymous
    #   @return [Hash] 匿名信息，如果不是匿名消息则为 null
    Target = Struct.new(:messagetype, :time, :group_id, :user_id, :message_id, :message, :raw_message, :sub_type, :anonymous)
    
    # 新建连接
    #
    # @param host [String]
    # @param port [Number]
    # @return [WebSocket]
    def self.connect(host:, port:)
      url = URI::WS.build(host: host, port: port)
      Api.setUrl()
      Utils.log '正在连接到 ' << url.to_s
      client = ::CQHttp::Bot::WebSocket.new(url)
      yield client if block_given?
      client.connect
      client
    end

    # WebSocket连接处理部分
    class WebSocket
      # @return [URI] WS URL
      attr_accessor :url
      # @return [Faye::WebSocket::Client] WS Conn
      attr_accessor :ws
      # @return [Number] self QQ id
      attr_accessor :selfID

      include EventEmitter

      # 设置 WS URL
      def initialize(url)
        @queueList = {}
        @url = url
      end

      # 连接 WS
      def connect
        EM.run do
          @ws = Faye::WebSocket::Client.new(@url.to_s)

          @ws.on :message do |event|
            Thread.new { dataParse(event.data) }
          end

          @ws.on :close do |event|
            emit :close, event
            Utils.log '连接断开'
            @ws = nil
            exit
          end

          @ws.on :error do |event|
            emit :error, event
            @ws = nil
          end
        end
      end

      # 发送私聊消息
      #
      # @param msg [String]
      # @param user_id [Number]
      # @return [Hash]
      def sendPrivateMessage(msg, user_id)
        echo = Time.now.to_i.to_s
        params = { action: 'send_private_msg', params: { user_id: user_id, message: msg }, echo: echo }.to_json
        @ws.send params
        @queueList[echo] = Queue.new
        ret = @queueList[echo].pop
        if parseRet(ret)
          Utils.log "发送至私聊 #{user_id} 的消息: #{msg} (#{ret['data']['message_id']})"
        else
          Utils.log "发送消息失败，错误码: #{ret['msg']}, 错误消息: #{ret['wording']}", Logger::WARN
        end
        return ret['data']
      end

      # 发送群聊消息
      #
      # @param msg [String]
      # @param group_id [Number]
      # @return [Hash]
      def sendGroupMessage(msg, group_id)
        echo = Time.now.to_i.to_s
        params = { action: 'send_group_msg', params: { group_id: group_id, message: msg }, echo: echo }.to_json
        @ws.send params
        @queueList[echo] = Queue.new
        ret = @queueList[echo].pop
        @queueList.delete(echo)
        if parseRet(ret)
          Utils.log "发送至群 #{group_id} 的消息: #{msg} (#{ret['data']['message_id']})"
        else
          Utils.log "发送消息失败，错误码: #{ret['msg']}, 错误消息: #{ret['wording']}", Logger::WARN
        end
        return ret['data']
      end
      
      # 发送消息
      # 根据 target [Struct] 自动选择
      #
      # @param msg [String]
      # @param target [Struct]
      # @return [Hash]
      def sendMessage(msg, target)
        return sendGroupMessage msg, target.group_id if target.messagetype == 'group'
        return sendPrivateMessage msg, target.user_id if target.messagetype == 'private'
      end

      private

      #
      #  解析API返回
      #
      def parseRet(ret)
        return true if ret['status'] == 'ok'
        return false if ret['status'] == 'failed'
      end
      #
      #  消息解析部分
      #
      def dataParse(data)
        msg = JSON.parse(data)
        sdr = Sender.new
        tar = Target.new
        tar.time = msg['time']
        if msg['meta_event_type'] == 'lifecycle' && msg['sub_type'] == 'connect'
          @selfID = msg['self_id']
          Utils.log "连接成功, BotQQ: #{@selfID}"
          emit :logged, @selfID
        end
        Utils.log data, Logger::DEBUG if msg['meta_event_type'] != 'heartbeat' # 过滤心跳
        #
        # 函数回调
        #
        if msg.include?('echo')
          @queueList[msg['echo']] << msg
        end
        case msg['post_type']
        #
        # 请求事件
        #
        when 'request'
          case msg['request_type']
          when 'group'
            Utils.log "收到用户 #{msg['user_id']} 加群 #{msg['group_id']} 的请求 (#{msg['flag']})" if msg['sub_type'] == 'add' # 加群请求
            Utils.log "收到用户 #{msg['user_id']} 的加群 #{msg['group_id']} 请求 (#{msg['flag']})" if msg['sub_type'] == 'invite' # 加群邀请
          when 'friend' # 加好友邀请
            Utils.log "收到用户 #{msg['user_id']} 的好友请求 (#{msg['flag']})"
          end
          emit :request, msg['request_type'], msg
        #
        # 提醒事件
        #
        when 'notice'
          case msg['notice_type']
          when 'group_admin' # 群管理员变动
            Utils.log "群 #{msg['group_id']} 内 #{msg['user_id']} 成了管理员" if msg['sub_type'] == 'set' # 设置管理员
            Utils.log "群 #{msg['group_id']} 内 #{msg['user_id']} 没了管理员" if msg['sub_type'] == 'unset' # 取消管理员
          when 'group_increase' # 群成员增加
            Utils.log "#{msg['operator_id']} 已同意 #{msg['user_id']} 进入了群 #{msg['group_id']}" if msg['sub_type'] == 'approve' # 管理员已同意入群
            Utils.log "#{msg['operator_id']} 邀请 #{msg['user_id']} 进入了群 #{msg['group_id']}" if msg['sub_type'] == 'invite' # 管理员邀请入群
          when 'group_decrease' # 群成员减少
            Utils.log "被 #{msg['operator_id']} 踢出了群 #{msg['group_id']}" if msg['sub_type'] == 'kick_me' # 登录号被踢
            Utils.log "#{msg['user_id']} 被 #{msg['operator_id']} 踢出了群 #{msg['group_id']}" if msg['sub_type'] == 'kick' # 成员被踢
            Utils.log "#{msg['operator_id']} 退出了群 #{msg['group_id']}" if msg['sub_type'] == 'leave' # 主动退群
          when 'group_ban' # 群禁言
            Utils.log "群 #{msg['group_id']} 内 #{msg['user_id']} 被 #{msg['operator_id']} 禁言了 #{msg['duration']} 秒" if msg['sub_type'] == 'ban' # 禁言
            Utils.log "群 #{msg['group_id']} 内 #{msg['user_id']} 被 #{msg['operator_id']} 解除禁言" if msg['sub_type'] == 'lift_ban' # 解除禁言
          when 'friend_add' # 好友添加
            Utils.log "#{msg['user_id']} 成了你的好友"
          when 'group_recall' # 群消息撤回
            Utils.log "群 #{msg['group_id']} 内 #{msg['user_id']} 撤回了一条消息 (#{msg['message_id']})"
          when 'friend_recall' # 好友消息撤回
            Utils.log "好友 #{msg['user_id']} 撤回了一条消息 (#{msg['message_id']})"
          end
          emit :notice, msg['notice_type'], msg
          
        #
        # 消息事件
        #
        when 'message'
          tar.user_id = msg['user_id'] # 用户id
          sdr.user_id = msg['sender']['user_id'] # 用户id
          tar.message_id = msg['message_id'] # 消息id
          tar.message = msg['message'] # 消息内容
          tar.raw_message = msg['raw_message'] # 消息内容
          sdr.age = msg['sender']['age'] # 年龄
          sdr.nickname = msg['sender']['nickname'] # 原有用户名
          sdr.sex = msg['sender']['sex'] # 性别
          tar.messagetype = msg['message_type'] # 消息类型
          tar.sub_type = msg['sub_type'] # 消息子类型
          # 下面仅群聊
          tar.group_id = msg['group_id'] # 群id
          tar.anonymous = msg['anonymous'] # 匿名信息
          sdr.card = msg['sender']['card'] # 群昵称
          sdr.title = msg['sender']['title'] # 头衔
          sdr.member_role = msg['sender']['role'] # 群成员地位
          sdr.qqlevel = msg['sender']['level'] # 群成员等级
          if tar.messagetype == 'group' # 判断是否为群聊
            Utils.log "收到群 #{tar.group_id} 内 #{sdr.nickname}(#{tar.user_id}) 的消息: #{tar.message} (#{tar.message_id})"
            emit :groupMessage, tar.message, sdr, tar
          else
            Utils.log "收到好友 #{sdr.nickname}(#{tar.user_id}) 的消息: #{tar.message} (#{tar.message_id})"
            emit :privateMessage, tar.message, sdr, tar
          end
          emit :message, tar.message, sdr, tar
        end
      end
    end
  end
end
