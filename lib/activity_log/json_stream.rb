require 'json'

# An Activity Log that uses the JSON Streaming format for storing entries
# @see https://en.wikipedia.org/wiki/JSON_streaming

module ActivityLog
  class JsonStream
    include FileHandleConcern

    # Create an ActivityLog
    #
    # @param file [String] The filename to create the log
    def initialize(file)
      @file = file
    end

    # Called at startup to perform any initialization
    def start; end

    # Record data in the log
    #
    # @data [Hash] A hash of data for the log entry
    def record(data)
      json = JSON.generate(data)
      file_handle.write(json, "\n")
    end

    # Called at shutdown to perform any final actions
    # For example writing data or closing handles
    def finish
      close_file_handle
    end

    private

    def file_open_mode
      super | File::APPEND
    end

  end
end
