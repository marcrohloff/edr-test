require 'etc'

# Class to lookup default values for attributes
#
# This class stores values that make sense to be global (like `caller_process_id`) or dynamic (like `timestamp`

module Command
  class Defaults

    def initialize
      initialize_lookup
    end

    # Check if the attribute name has a default value
    #
    #@param name [Symbol]  name to check for in default table
    #@result     [Boolean] `true` if the `name` has a default
    def has?(name)
      name = name.to_sym
      @value_lookup.key?(name)
    end

    # Return the default value for an attribute name
    #
    #@param name [Symbol] name to lookup in default table
    #@result     [Any]
    def fetch(name)
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
      # This table can contain a lookup or a Proc
      # If a proc is used then it is called to calculate a dynamic (changing) value
      @value_lookup = {
        timestamp:              -> { Time.now.to_f },
        username:               Etc.getlogin,
        caller_process_cmdline: process_command_line,
        caller_process_name:    $PROGRAM_NAME,
        caller_process_id:      Process.pid,
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
