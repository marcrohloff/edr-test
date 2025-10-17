require 'etc'

module DataSource
  class Defaults

    def initialize
      initialize_lookup
    end

    def contains?(name)
      name = name.to_sym
      @value_lookup.key?(name)
    end

    def lookup(name)
      name = name.to_sym
      entry = @value_lookup[name]
      return nil unless entry

      if entry.is_a?(Proc)
        entry.call
      else
        entry
      end
    end

    private

    def initialize_lookup
      @value_lookup = {
        timestamp:              -> { Time.now.to_f },
        username:               Etc.getlogin,
        caller_process_cmdline: process_command_line,
        caller_process_name:    $PROGRAM_NAME,
        caller_process_pid:     Process.pid,
        protocol:               'tcp'
      }
    end

    # This is not perfect but this is the best information that ruby gives
    def process_command_line
      @process_command_line ||= begin
                                  cmdline = `ps -fh --pid=#{Process.pid} -o "%a"`.chomp.presence
                                  cmdline || $PROGRAM_NAME
                                end
    end

  end
end
