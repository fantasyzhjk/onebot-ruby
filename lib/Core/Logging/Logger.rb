module Onebot
  module Logging
    class Logger
      # @!method stdLogger
      #   @return [Logger] 终端Logger
      # @!method fileLogger
      #   @return [Logger] 文件Logger
      # @!method loggerFile
      #   @return [String] Logger文件地址
      attr_accessor :stdLogger, :fileLogger, :loggerFile
      # 初始化日志
      #
      # @param loggerFile [String]
      def initialize(loggerFile = nil)
        @loggerFile = loggerFile
        @stdLogger = setLogger(::Logger.new(STDOUT))
        @fileLogger = setLogger(::Logger.new(@loggerFile, "daily")) if @loggerFile
      end

      # 设置日志等级
      #
      # @param loggerLevel [String]
      def setLoggerLevel(loggerLevel)
        @stdLogger.level = loggerLevel
        @fileLogger.level = loggerLevel if @loggerFile
        self
      end

      # 输出日志
      #
      # @param str [String]
      # @param severity [Logger::INFO, Logger::DEBUG, Logger::WARN, Logger::ERROR]
      # @param app [String]
      def log(str, severity = ::Logger::INFO, app = "Onebot")
        @stdLogger.log(severity, str, app)
        @fileLogger.log(severity, str, app) if @loggerFile
      end

      private

      # 设置logger
      def setLogger(logger)
        logger.level = "INFO"
        logger.formatter = proc do |severity, datetime, progname, msg|
          if progname == nil
            "[#{datetime.strftime("%Y-%m-%d %H:%M:%S")}][#{severity}]: #{msg.to_s.gsub(/\n/, '\n').gsub(/\r/, '\r')}\n"
          else
            "[#{datetime.strftime("%Y-%m-%d %H:%M:%S")}][#{progname}][#{severity}]: #{msg.to_s.gsub(/\n/, '\n').gsub(/\r/, '\r')}\n"
          end
        end
        logger
      end
    end
  end
end
