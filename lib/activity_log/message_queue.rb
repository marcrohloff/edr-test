module ActivityLog
  class MessageQueue
    attr_reader :hostname, :queue_name

    def initialize(hostname, queue_name)
      @hostname   = hostname
      @queue_name = queue_name
    end

    def start
      @mq_server = connect(hostname, queue_name) #tbd
    end

    def record(data)
      @mq_server.queue(data)
    end

    def finish
      @mq_server.disconnect #tbd
    end

  end
end
