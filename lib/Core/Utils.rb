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
      req = Net::HTTP::Post.new(url.path, { "Content-Type" => "application/json" })
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
    def msg_change(msg)
      msg.gsub!("&amp;", "&")
      msg.gsub!("&#91;", "[")
      msg.gsub!("&#93;", "]")
      msg
    end

    # 消息反转义
    # & -> &amp;
    # [ -> &#91;
    # ] -> &#93;
    #
    # @param msg [String]
    # @return [String]
    def msg_change!(msg)
      msg.gsub!("&", "&amp;")
      msg.gsub!("[", "&#91;")
      msg.gsub!("]", "&#93;")
      msg
    end

    # CQ码解析
    #
    # @param cqmsg [String]
    # @return [Hash]
    def cq_parse(cqmsg)
      cqary = []
      cqmsg.scan(/\[CQ:(.*?),(.*?)\]/m).each do |matches|
        cqcode = { type: matches[0], data: {} }
        matches[1].split(",").each do |arg|
          args = arg.split("=")
          cqcode[:data][args[0].to_sym] = args[1]
        end
        cqary << cqcode
      end
      cqary
    end
  end
end
