module CQHttp
  class Utils
    attr_accessor :stdLogger, :fileLogger, :loggerFile
    class << self
      def setLogger(logger)
        logger.level = 'INFO'
        logger.formatter = proc do |severity, datetime, progname, msg|
            if progname == nil
                "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}][#{severity}]: #{msg}\n"
            else
                "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}][#{progname}][#{severity}]: #{msg}\n"
            end
        end
        logger
      end
      def initLogger(loggerFile=nil)
        @loggerFile = loggerFile
        @stdLogger = setLogger(Logger.new(STDOUT))
        @fileLogger = setLogger(Logger.new(@loggerFile, 'daily')) if @loggerFile
      end

      def setLoggerLevel(loggerLevel)
        @stdLogger.level = loggerLevel
        @fileLogger.level = loggerLevel if @loggerFile
      end

      def log(str, severity=Logger::INFO, app="RUBY-CQHTTP")
        @stdLogger.log(severity, "#{str}", app)
        @fileLogger.log(severity, "#{str}", app) if @loggerFile
      end

      def httpPost(url, ret)
        req = Net::HTTP::Post.new(url.path, { 'Content-Type' => 'application/json' })
        req.body = ret
        res = Net::HTTP.start(url.hostname, url.port) do |http|
          http.request(req)
        end
        res.body
      end
    end
  end
end
