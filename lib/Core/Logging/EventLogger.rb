module Onebot
  module Logging
    class EventLogger
      def initialize(logger = nil)
        @logger = logger
      end

      def log(str, severity = ::Logger::INFO, app = "Onebot")
        return if @logger == nil
        @logger.log(str, severity, app)
      end

      #
      #  消息解析部分
      #
      def dataParse(msg)
        return if @logger == nil
        # 连接成功
        if msg.meta_event_type == "lifecycle" && msg.sub_type == "connect"
          @selfID = msg.self_id
        end
        @logger.log msg.to_json, ::Logger::DEBUG if msg.meta_event_type != "heartbeat" # 过滤心跳
        case msg.post_type
        #
        # 请求事件
        #
        when "request"
          case msg.request_type
          when "group"
            if msg.sub_type == "add"
              @logger.log "收到用户 #{msg.user_id} 加群 #{msg.group_id} 的请求 (#{msg.flag})"
            end # 加群请求
            if msg.sub_type == "invite"
              @logger.log "收到用户 #{msg.user_id} 的加群 #{msg.group_id} 请求 (#{msg.flag})"
            end # 加群邀请
          when "friend" # 加好友邀请
            @logger.log "收到用户 #{msg.user_id} 的好友请求 (#{msg.flag})"
          end
          #
          # 提醒事件
          #
        when "notice"
          case msg.notice_type
          when "group_admin" # 群管理员变动
            @logger.log "群 #{msg.group_id} 内 #{msg.user_id} 成了管理员" if msg.sub_type == "set" # 设置管理员
            @logger.log "群 #{msg.group_id} 内 #{msg.user_id} 没了管理员" if msg.sub_type == "unset" # 取消管理员
          when "group_increase" # 群成员增加
            if msg.sub_type == "approve"
              @logger.log "#{msg.operator_id} 已同意 #{msg.user_id} 进入了群 #{msg.group_id}"
            end # 管理员已同意入群
            if msg.sub_type == "invite"
              @logger.log "#{msg.operator_id} 邀请 #{msg.user_id} 进入了群 #{msg.group_id}"
            end # 管理员邀请入群
          when "group_decrease" # 群成员减少
            @logger.log "被 #{msg.operator_id} 踢出了群 #{msg.group_id}" if msg.sub_type == "kick_me" # 登录号被踢
            if msg.sub_type == "kick"
              @logger.log "#{msg.user_id} 被 #{msg.operator_id} 踢出了群 #{msg.group_id}"
            end # 成员被踢
            @logger.log "#{msg.operator_id} 退出了群 #{msg.group_id}" if msg.sub_type == "leave" # 主动退群
          when "group_ban" # 群禁言
            if msg.sub_type == "ban"
              @logger.log "群 #{msg.group_id} 内 #{msg.user_id} 被 #{msg.operator_id} 禁言了 #{msg.duration} 秒"
            end # 禁言
            if msg.sub_type == "lift_ban"
              @logger.log "群 #{msg.group_id} 内 #{msg.user_id} 被 #{msg.operator_id} 解除禁言"
            end # 解除禁言
          when "friend_add" # 好友添加
            @logger.log "#{msg.user_id} 成了你的好友"
          when "group_recall" # 群消息撤回
            @logger.log "群 #{msg.group_id} 内 #{msg.user_id} 撤回了一条消息 (#{msg.message_id})"
          when "friend_recall" # 好友消息撤回
            @logger.log "好友 #{msg.user_id} 撤回了一条消息 (#{msg.message_id})"
          end
          #
          # 消息事件
          #
        when "message"
          if msg.message_type == "group" # 判断是否为群聊
            @logger.log "收到群 #{msg.group_id} 内 #{msg.sender.nickname}(#{msg.user_id}) 的消息: #{msg.raw_message} (#{msg.message_id})"
          else
            @logger.log "收到好友 #{msg.sender.nickname}(#{msg.user_id}) 的消息: #{msg.raw_message} (#{msg.message_id})"
          end
        end
      end
    end
  end
end
