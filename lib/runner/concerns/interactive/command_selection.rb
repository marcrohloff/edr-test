module Runner
  module Interactive
    module CommandSelection
      extend ActiveSupport::Concern

      private

      def select_command_class
        display_command_choices

        command_index = read_command_index
        command_classes[command_index] if command_index
      end

      def read_command_index
        loop do
          command_index = input.readline.chomp
          return nil unless command_index.presence

          command_index = command_index.to_i - 1

          break command_index if command_index >= 0 && command_index < command_classes.count

          output.puts 'Invalid command number. Please try again:'
        end
      end

      def command_classes
        Command.command_classes
      end

      def display_command_choices
        output.puts
        output.puts 'Available commands:'
        command_classes.each.with_index do |command_class, i|
          output.puts "  (#{i + 1}) #{human_command_name(command_class)}"
        end
        output.puts 'Choose a command number [enter to quit]:'
      end

      def human_command_name(command_class)
        name = command_class.name.demodulize.underscore
        name.to_s
            .humanize(keep_id_suffix: true)
            .titleize(keep_id_suffix: true)
      end

    end
  end
end
