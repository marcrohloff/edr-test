module Command
  class StartProcess < Base
    include ActivityConcern

    attribute :started_process_cmdline, :string

    attr_reader :started_process_pid # output only value

    validates :started_process_cmdline,
              presence: true

    def self.activity_type = :process_start

    def execute!
      # Run the process in the background so that it doesn't block
      pid = Process.spawn(started_process_cmdline)
      Process.detach(pid)

      @started_process_pid = pid
    end

    def activity_log_data
      readonly_attributes = { started_process_pid: }.compact
      super.merge(readonly_attributes)
    end

  end
end
