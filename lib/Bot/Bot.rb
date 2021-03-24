module CQHttp
  # connect
  #
  # Example:
  #   bot = CQHttp::Bot.connect host: host, port: port
  class Bot
    Sender = Struct.new(:age, :member_role, :card, :qqlevel, :nickname, :title, :sex)
    Target = Struct.new(:messagetype, :time, :group_id, :user_id, :message_id, :message)
    
    # 连接 ws
    #
    # @param host [String]
    # @param port [Number]
    # @return [Class]
    def self.connect(host:, port:)
      url = URI::WS.build(host: host, port: port)
      Api.setUrl()
      Utils.log '正在连接到 ' << url.to_s
      client = ::CQHttp::Bot::WebSocket.new(url)
      yield client if block_given?
      client.connect
      client
    end

    class WebSocket
      attr_accessor :url
      attr_accessor :ws
      attr_accessor :selfID

      include EventEmitter

      def initialize(url)
        @url = url
      end

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
      def sendPrivateMessage(msg, user_id)
        ret = { action: 'send_private_msg', params: { user_id: user_id, message: msg }, echo: 'BotPrivateMessage' }.to_json
        Utils.log "发送至私聊 #{user_id} 的消息: #{msg}"
        @ws.send ret
      end

      # 发送群聊消息
      #
      # @param msg [String]
      # @param group_id [Number]
      def sendGroupMessage(msg, group_id)
        ret = { action: 'send_group_msg', params: { group_id: group_id, message: msg }, echo: 'BotGroupMessage' }.to_json
        Utils.log "发送至群 #{group_id} 的消息: #{msg}"
        @ws.send ret
      end
      
      # 发送消息
      # 根据 target [Struct] 自动选择
      #
      # @param msg [String]
      # @param target [Struct]
      def sendMessage(msg, target)
        sendGroupMessage msg, target.group_id if target.messagetype == 'group'
        sendPrivateMessage msg, target.user_id if target.messagetype == 'private'
      end

      private

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
        Utils.log msg, Logger::DEBUG if msg['meta_event_type'] != 'heartbeat' # 过滤心跳
        case msg['post_type']
        #
        # 请求事件
        #
        when 'request'
          case msg['request_type']
          when 'group'
            if msg['sub_type'] == 'invite' # 加群邀请
              Utils.log "收到用户 #{msg['user_id']} 的加群 #{msg['group_id']} 请求 (#{msg['flag']})"
            end
          when 'friend' # 加好友邀请
            Utils.log "收到用户 #{msg['user_id']} 的好友请求 (#{msg['flag']})"
          end
          emit :request, msg['request_type'], msg['sub_type'], msg['flag']
        #
        # 提醒事件
        #
        when 'notice'
          case msg['notice_type']
          when 'group_decrease' # 群数量减少
            if msg['sub_type'] == 'kick_me' # 被踢出
              Utils.log "被 #{msg['operator_id']} 踢出群 #{msg['group_id']}"
            end
          when 'group_recall'
            Utils.log "群 #{msg['group_id']} 中 #{msg['user_id']} 撤回了一条消息 (#{msg['message_id']})"
          when 'friend_recall'
            Utils.log "好友 #{msg['user_id']} 撤回了一条消息 (#{msg['message_id']})"
          end
          emit :notice, msg['notice_type'], msg
          
        #
        # 消息事件
        #
        when 'message'
          tar.user_id = msg['user_id'] # 用户id
          tar.message_id = msg['message_id'] # 消息id
          tar.message = msg['message'] # 消息内容
          sdr.age = msg['sender']['age'] # 年龄
          sdr.nickname = msg['sender']['nickname'] # 原有用户名
          sdr.sex = msg['sender']['sex'] # 性别
          tar.messagetype = msg['message_type'] # 消息类型
          # 下面仅群聊
          tar.group_id = msg['group_id'] # 群id
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
