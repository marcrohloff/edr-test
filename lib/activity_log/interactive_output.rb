# An Activity Log that displays output to the interactive display
#
# See ActiityLog::JsonStream for documentation

module ActivityLog
  class InteractiveOutput

    attr_reader :output

    def initialize(output)
      @output = output
    end

    def start; end

    def record(data)
      output.puts(">> Activity: #{data.inspect}")
    end

    def finish; end

  end
end
