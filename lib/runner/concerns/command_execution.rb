# A cern for executing a command
#
# Standardizes what happens when a command is executed
#   (Validation, dry run, logging, error handling)

module Runner
  module CommandExecution
    extend ActiveSupport::Concern

    private

    # Execute a command with validation, logging and error handling
    #
    # @param command [Command] The command to execute
    def execute_command(command)
      logger.info("Running #{command.command_name.inspect}")

      unless command.valid?
        logger.warn("Validation Errors: #{command.errors.full_messages.join(', ')}")
        display_validation_errors(command)
        return false
      end

      unless dry_run
        begin
          command.execute!
        rescue => ex
          logger.error("Error: #{ex.inspect}")
          display_exception(ex)
          return false
        end
      end

      activity_log.record(command.activity_log_data) if command.respond_to?(:activity_log_data)
      logger.info("Completed #{command.class}")

      true
    end

    def display_validation_errors(command)
      output.puts("The parameters for #{command.command_name} were invalid:")
      command.errors.full_messages.each { output.puts "  #{it}" }
    end

    def display_exception(ex)
      message = "An exception occurred: #{ex.message}"
      message += " (#{ex.class})" unless ex.respond_to?(:quiet_exception)
      output.puts(message)
    end

  end

end
