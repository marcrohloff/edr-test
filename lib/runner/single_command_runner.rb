module Runner
  class SingleCommandRunner < Base

    attr_reader :command_class, :data_source

    def initialize(command_class, data_source, context)
      super(context)
      @command_class = command_class
      @data_source   = data_source
    end

    def run
      attributes = data_source.attributes_for(command_class)
      logger.info("Running #{command_class} with #{attributes.inspect}")

      command = command_class.new(**attributes)
      command.validate!

      command.execute! unless context.dry_run

      context.activity_log.record(command.activity_log_entry)

      logger.info("Completed #{command_class}")

      true
    end

  end
end
