module CQHttp
  # 各种工具包
  #
  # Example:
  #   CQHttp::Utils.log str, Logger::INFO
  class Utils
    attr_accessor :stdLogger, :fileLogger, :loggerFile
    class << self

      # 初始化日志
      #
      # @param loggerFile [String]
      def initLogger(loggerFile=nil)
        @loggerFile = loggerFile
        @stdLogger = setLogger(Logger.new(STDOUT))
        @fileLogger = setLogger(Logger.new(@loggerFile, 'daily')) if @loggerFile
      end
      
      # 设置日志等级
      #
      # @param loggerLevel [String]
      def setLoggerLevel(loggerLevel)
        @stdLogger.level = loggerLevel
        @fileLogger.level = loggerLevel if @loggerFile
      end
      
      # 输出日志
      #
      # @param str [String]
      # @param severity [Logger::INFO, Logger::DEBUG, Logger::WARN, Logger::ERROR]
      # @param app [String]
      def log(str, severity=Logger::INFO, app="RUBY-CQHTTP")
        @stdLogger.log(severity, str, app)
        @fileLogger.log(severity, str, app) if @loggerFile
      end
      
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
      def msg_change(msg)
        msg.gsub!('&amp;','&')
        msg.gsub!('&#91;','[')
        msg.gsub!('&#93;',']')
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
        msg.gsub!('&','&amp;')
        msg.gsub!('[','&#91;')
        msg.gsub!(']','&#93;')
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
          matches[1].split(',').each do |arg|
            args = arg.split('=')
            cqcode[:data][args[0].to_sym] = args[1]
          end
          cqary << cqcode
        end
        cqary
      end

      private

      # 设置logger
      def setLogger(logger)
        logger.level = 'INFO'
        logger.formatter = proc do |severity, datetime, progname, msg|
            if progname == nil
                "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}][#{severity}]: #{msg.to_s.gsub(/\n/,'\n').gsub(/\r/,'\r') }\n"
            else
                "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}][#{progname}][#{severity}]: #{msg.to_s.gsub(/\n/,'\n').gsub(/\r/,'\r') }\n"
            end
        end
        logger
      end
    end
  end
end
