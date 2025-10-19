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

  def temp_file_name(extension = nil)
    fn = Dir::Tmpname.create('') { it }

    if extension
      extension = '.' + extension unless extension.start_with?('.')
      fn = fn.sub(/(\.[^.]*)?$/,  # make sure we only get the last '.'
                   extension)
    end

    fn
  end

end
