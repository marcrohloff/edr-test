require 'json'

# An Activity Log that rites a single JSON representation for all entries to a file
#
# See ActiityLog::JsonStream for documentation

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
      json = JSON.pretty_generate(@records)
      file_write(json)
    end

  end
end
