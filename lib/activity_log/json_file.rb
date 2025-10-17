require 'json'

require_relative 'concerns/file_handle_concern'

module ActivityLog
  class JsonFile
    include FileHandleConcern

    def initialize(file)
      @file    = file
      @records = []
    end

    def start; end

    def record(data)
      @records << data
    end

    def finish
      json = JSON.generate(@records)
      file_write(json)
    end

  end
end
