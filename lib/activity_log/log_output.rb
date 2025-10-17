module ActivityLog
  class LogOutput
    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def start; end

    def record(data)
      logger.info("Activity: #{data.inspect}")
    end

    def finish; end

  end
end
