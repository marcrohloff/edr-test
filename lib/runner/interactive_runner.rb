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

    def run
      loop do
        command_class = select_command_class
        break unless command_class

        process_one_command(command_class)
      end
    end

    private

    def process_one_command(command_class)
      command = command_class.new
      assign_attributes(command)

      execute_command(command)
    end

    def display_validation_errors(ex, command)
      super

      command = ex.model
      output.puts("The parameters were invalid:")
      command.errors.full_messages.each { output.puts "  #{it}" }
      output.puts("Please try again")
    end

    def display_exception(ex)
      super

      output.puts("An exception occurred: #{ex.message}. Try again")
    end

  end
end
