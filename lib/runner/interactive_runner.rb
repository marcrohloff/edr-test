module Runner
  class InteractiveRunner < Base

    def run
      loop do
        command_class = choose_command_class
        break unless command_class

        execute_command_until_success(command_class)
      end
    end

    private

    delegate :input, :output, to: :context

    def choose_command_class
      display_command_choices
      command_index = choose_command_index
      command_classes[command_index] if command_index
    end

    def choose_command_index
      loop do
        command_index = read_command_index
        return nil if command_index.nil?
        break command_index if command_index >= 0 && command_index < command_classes.count
        output.puts 'Invalid command number. Please try again:'
      end
    end

    def display_command_choices
      output.puts
      output.puts 'Available commands:'
      command_classes.each.with_index do |command_class, i|
        output.puts "  (#{i + 1}) #{human_command_name(command_class)}"
      end
      output.puts 'Choose a command number [enter to quit]:'
    end

    def read_command_index
      command_index = input.readline.chomp
      return nil unless command_index.presence

      command_index.to_i - 1
    end

    # For interactive sessions we repeat the command until it succeeds
    def execute_command_until_success(command_class)
      runner = SingleCommandRunner.new(command_class, data_source, context)

      loop do
        success = execute_command(command_class)
        break if success
      end
    end

    def execute_command(command_class)
      runner = SingleCommandRunner.new(command_class, data_source, context)
      runner.run

    rescue ActiveModel::ValidationError => ex
      display_validation_errors(ex)
      false

    rescue StandardError => ex
      display_exception(ex)
      false
    end

    def display_validation_errors(ex)
      command = ex.model
      output.puts("The parameters were invalid:")
      command.errors.full_messages.each { output.puts "  #{it}" }
      output.puts("Please try again")
    end

    def display_exception(ex)
      output.puts("An exception occurred: #{ex.message}. Try again")
    end

    def data_source
      @data_source ||= DataSource::InteractiveSource.new(context:)
    end

    def command_classes
      @command_classes ||= Command::Base.command_classes
    end

    def human_command_name(command_class)
      name = command_class.name.demodulize.underscore
      name.to_s
          .humanize(keep_id_suffix: true)
          .titleize(keep_id_suffix: true)
    end

  end
end
