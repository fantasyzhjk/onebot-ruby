module Onebot
  # 各种工具包
  #
  # Example:
  #   Onebot::Utils.log str, Logger::INFO
  module Utils
    extend self
    # post发包
    #
    # @param url [URI]
    # @param ret [String]
    # @return [String]
    def httpPost(url, ret)
      req = Net::HTTP::Post.new(url.path, { 'Content-Type' => 'application/json' })
      req.body = ret
      res = Net::HTTP.start(url.hostname, url.port) do |http|
        http.request(req)
      end
      res.body
    end

    alias post httpPost
    # 消息转义
    # &amp; -> &
    # &#91; -> [
    # &#93; -> ]
    #
    # @param msg [String]
    # @return [String]
    def cqEscape(msg)
      msg.gsub!('&amp;', '&')
      msg.gsub!('&#91;', '[')
      msg.gsub!('&#93;', ']')
      msg
    end

    # 消息反转义
    # & -> &amp;
    # [ -> &#91;
    # ] -> &#93;
    #
    # @param msg [String]
    # @return [String]
    def cqUnescape(msg)
      msg.gsub!('&', '&amp;')
      msg.gsub!('[', '&#91;')
      msg.gsub!(']', '&#93;')
      msg
    end

    # CQ码解析, 将字符串格式转换成 Onebot v11 的消息段数组格式
    #
    # @param cqmsg [String]
    # @return [Array]
    def cqParse(cqmsg)
      msgary = []
      cqary = cqmsg.scan(/\[CQ:(.*?),(.*?)\]/m)
      isCode = false
      i = 0
      temp = ''
      cqmsg.each_char do |c|
        if isCode
          if c == ']'
            isCode = false
            matches = cqary[i]
            cqcode = { type: matches[0], data: {} }
            matches[1].split(',').each do |arg|
              args = arg.split('=')
              cqcode[:data][args[0].to_sym] = args[1]
            end
            msgary << cqcode
          end
        elsif c == '['
          msgary << { type: 'text', data: { text: cqEscape(temp) } }
          temp = ''
          isCode = true
        else
          temp << c
        end
      end
      msgary << { type: 'text', data: { text: cqEscape(temp) } } unless temp.empty?
      msgary
    end
  end
end
