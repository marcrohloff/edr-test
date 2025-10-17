require 'tempfile'

module SpecHelperMethods
  extend ActiveSupport::Concern

  class RecordingLogger
    attr_reader :records
    def initialize; @records = []; end

    def info(message)  = log(:info, message)
    def warn(message) = log(:warn, message)
    def error(message) = log(:error, message)

    private def log(type, message)
      records << "#{type.to_s.upcase}: #{message}"
    end
  end

  class RecordingActivityLog
    attr_reader :records
    def initialize; @records = []; end
    def record(message)
      records << message
    end
  end

  def temp_file_name
    Dir::Tmpname.create('') { it }
  end

end
