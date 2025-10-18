require 'json'

module ActivityLog
  class JsonStream
    include FileHandleConcern

    def initialize(file)
      @file = file
    end

    def start; end

    def record(data)
      json = JSON.generate(data)
      file_handle.write(json, "\n")
    end

    def finish
      close_file_handle
    end

    private

    def file_open_mode
      super | File::APPEND
    end

  end
end
