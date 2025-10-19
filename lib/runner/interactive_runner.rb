# A runner to run a request loop for the interactive UI
#
# Requests commands until no command is selcted

module Runner
  class InteractiveRunner
    include Runner::Errors
    include Runner::CommandExecution
    include Runner::InteractiveCommandSelection
    include Runner::InteractiveAttributeEntry

    attr_reader :input, :output,
                :logger, :activity_log, :defaults,
                :dry_run

    def initialize(input:, output:,
                   logger:, activity_log:, defaults:,
                   dry_run:)
      @input        = input
      @output       = output
      @logger       = logger
      @activity_log = activity_log
      @defaults     = defaults
      @dry_run      = dry_run
    end

    # Run main command request loop until enter is pressed
    def run
      loop do
        command_class = select_command_class
        break unless command_class

        process_one_command(command_class)
      end

      nil
    end

    private

    def process_one_command(command_class)
      command = command_class.new
      assign_attributes(command)

      success = execute_command(command)
      output.puts("Please try again") unless success
      success
    end

  end
end
