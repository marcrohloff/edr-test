####################################
# Proof of concept

module Runner
  class FileInputRunner
    include Runner::Errors
    include Runner::AttributeHelpers
    include Runner::CommandExecution

    attr_reader :filename,
                :logger, :activity_log, :defaults,
                :dry_run

    def initialize(filename:,
                   logger:, activity_log:, defaults:,
                   dry_run:)
      @filename     = filename
      @logger       = logger
      @activity_log = activity_log
      @defaults     = defaults
      @dry_run      = dry_run
    end

    def run
      File.for_each(filename) do |line|
        run_one_line(line)
      end
    end

    private

    def run_one_line(line_data)
      command_class, attributes = parse_line(line_data)
      command = command_class.new

      assign_attributes(command, attributes)
      execute_command(command)
    end

    def assign_attributes(command, attributes)
      attribute_names = command.attribute_names.map(&:to_sym)

      extra_keys = data.keys - attributes
      raise RunnerError, "Data source contains extra keys #{extra_keys}" if extra_keys.present?

      # Setting attributes one by one so attributes can have side effects that cascade to later attributes
      attribute_names.each do |attribute_name|
        value = attributes[attribute_name] || default_attribute_value(attribute_name)
        command.assign_attributes(attribute_name => value)
      end

    end

  end
end
