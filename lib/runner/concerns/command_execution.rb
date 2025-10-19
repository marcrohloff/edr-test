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

      command.validate!
      command.execute! unless dry_run

      activity_log.record(command.activity_log_data) if command.respond_to?(:activity_log_data)
      logger.info("Completed #{command.class}")

      true

    rescue ActiveModel::ValidationError => ex
      display_validation_errors(ex, command)
      false

    # Re-raise exceptions that will get us stuck in an infinite loop
    rescue EOFError => ex
      display_exception(ex)
      raise

    rescue StandardError => ex
      display_exception(ex)
      false
    end

    def display_validation_errors(ex, _command)
      logger.warn("Validation Error: #{ex.inspect}")
    end

    def display_exception(ex)
      logger.error("Error: #{ex.inspect}")
    end

  end

end
