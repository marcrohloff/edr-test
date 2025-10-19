require 'json'
require 'yaml'

# A runner to loop through entries in a script file and run command
# @note: This is a proof of concept and is incomplete

module Runner
  class ScriptFileRunner
    include Runner::Errors
    include Runner::AttributeHelpers
    include Runner::CommandExecution

    attr_reader :filename,
                :output, :logger, :activity_log, :defaults,
                :dry_run

    def initialize(filename:,
                   output:, logger:, activity_log:, defaults:,
                   dry_run:)
      @filename     = filename
      @output       = output
      @logger       = logger
      @activity_log = activity_log
      @defaults     = defaults
      @dry_run      = dry_run
    end

    def run
      logger.info("Reading script from #{@filename}")
      load_file(filename)

      script_lines.each do |line_data|
        success = run_one_script_command(line_data)
        return 1 if !success
      end

      output.puts("Script #{filename} completed successfully")
      logger.info("Script #{filename} completed successfully")
      nil

    rescue RunnerError => ex
      output.puts(ex.message)
      output.puts('Terminating script')
      return 2

    rescue => ex
      output.puts("Error: #{ex.message} (#{ex.class})")
      output.puts('Terminating script')
      raise
    end

    private

    attr_reader :script_lines

    def load_file(filename)
      ext = File.extname(filename)&.downcase

      case ext
      when '.yaml',  '.yml'
        @script_lines = YAML.load_file(filename, aliases: true, symbolize_names: true)

      when '.json'
        @script_lines = JSON.load_file(filename, symbolize_names: true)

      else
       raise RunnerError, "Unsuported file type #{ext.inspect}"

      end
    end

    def run_one_script_command(line_data)
      command_class, attributes = parse_script_command(line_data)
      output.puts "Running #{command_class.command_name} with attributes #{attributes}"

      command = command_class.new
      assign_attributes(command, attributes)

      success = execute_command(command)
      output.puts success ? '' : 'Terminating script'
      success
    end

    def parse_script_command(line_data)
      command_name  = line_data[:command]
      command_class = lookup_command_class(command_name)
      attributes    = line_data.except(:command)
      [command_class, attributes]
    end

    def lookup_command_class(command_name)
      command_name  = command_name&.to_sym
      if valid_command_names.exclude?(command_name)
        raise RunnerError, <<~MSG
          Unknown command name "#{command_name}"
            Valid command_names are: #{valid_command_names.join(', ')}
        MSG
      end

      command_classes[command_name]
   end

    def command_classes
      @command_classes ||= Command.command_classes
                                  .index_by(&:command_name)
    end

    def valid_command_names
      command_classes.keys
    end

    def assign_attributes(command, attributes)
      attribute_names = command.attribute_names.map(&:to_sym)

      unknown_keys = attributes.keys - attribute_names
      raise RunnerError, "Attributes contains unknown keys (#{unknown_keys.join(', ')}) for #{command.command_name}" if unknown_keys.present?

      # Setting attributes one by one so attributes can have side effects that cascade to later attributes
      attribute_names.each do |attribute_name|
        value = attributes[attribute_name] || default_attribute_value(attribute_name, command)
        command.assign_attributes(attribute_name => value)
      end

    end

  end
end
