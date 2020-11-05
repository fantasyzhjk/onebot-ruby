module CQHttp
  class Bot
    Sender = Struct.new(:age, :member_role, :card, :qqlevel, :nickname, :title, :sex)
    Target = Struct.new(:messagetype, :time, :group_id, :user_id, :message_id, :message)

    def self.connect(url, debugmode=false)
      client = ::CQHttp::Bot::WebSocket.new(url, debugmode)
      yield client if block_given?
      client.connect
      client
    end

    class WebSocket
      attr_accessor :url
      attr_accessor :debugmode
      attr_accessor :selfID

      include EventEmitter

      def initialize(url, debugmode)
        @url = url
        @debugmode = debugmode
      end

      def connect
        EM.run do
          @ws = Faye::WebSocket::Client.new(@url)

          @ws.on :open do
          end

          @ws.on :message do |event|
            Thread.new { dataParse(event.data)}
          end

          @ws.on :close do
            emit :close
            puts '已断开链接'
            @ws = nil
            exit
          end

          @ws.on :error do |event|
            emit :error, event
            @ws = nil
          end
        end
      end


      def sendPrivateMessage(msg, user_id)
        ret = { action: 'send_private_msg', params: { user_id: user_id, message: msg }, echo: 'BotPrivateMessage' }.to_json
        puts "[#{Time.new.strftime('%Y-%m-%d %H:%M:%S')}][↑]: 发送至私聊 #{user_id} 的消息: #{msg}"
        @ws.send ret
      end

      def sendGroupMessage(msg, group_id)
        ret = { action: 'send_group_msg', params: { group_id: group_id, message: msg }, echo: 'BotGroupMessage' }.to_json
        puts "[#{Time.new.strftime('%Y-%m-%d %H:%M:%S')}][↑]: 发送至群 #{group_id} 的消息: #{msg}"
        @ws.send ret
      end

      private

      def dataParse(data)
        msg = JSON.parse(data)
        sdr = Sender.new
        tar = Target.new
        tar.time = msg['time']
        if msg['meta_event_type'] == 'lifecycle' && msg['sub_type'] == 'connect'
          @selfID = msg['self_id']
          puts "[#{Time.at(tar.time).strftime('%Y-%m-%d %H:%M:%S')}][!]: go-cqhttp连接成功, BotQQ: #{@selfID}"
          emit :logged, @selfID
        end
        if @debugmode == true
          puts msg if msg['meta_event_type'] != 'heartbeat'
        end
        if msg['post_type'] == 'message'
          tar.user_id = msg['user_id']
          tar.message_id = msg['message_id']
          tar.message = msg['message']
          sdr.age = msg['sender']['age']
          sdr.nickname = msg['sender']['nickname'] # 原有用户名
          sdr.sex = msg['sender']['sex']
          tar.messagetype = msg['message_type']
          # Group only
          tar.group_id = msg['group_id']
          sdr.card = msg['sender']['card'] # 群昵称
          sdr.title = msg['sender']['title'] # 头衔
          sdr.member_role = msg['sender']['role']
          sdr.qqlevel = msg['sender']['level']
          if tar.messagetype == 'group'
            puts "[#{Time.at(tar.time).strftime('%Y-%m-%d %H:%M:%S')}][↓]: 收到群 #{tar.group_id} 内 #{sdr.nickname}(#{tar.user_id}) 的消息: #{tar.message} (#{tar.message_id})"
            emit :groupMessage, tar.message, sdr, tar
          else
            puts "[#{Time.at(tar.time).strftime('%Y-%m-%d %H:%M:%S')}][↓]: 收到好友 #{sdr.nickname}(#{tar.user_id}) 的消息: #{tar.message} (#{tar.message_id})"
            emit :privateMessage, tar.message, sdr, tar
          end
          emit :message, tar.message, sdr, tar
        end
      end
    end
  end
end
