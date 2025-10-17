require_relative './concerns/file_concern'

module Command
  class ModifyFile < Base
    include FileConcern

    def execute!
      # Raise an exception if the file doesn't exist
      File.open(file_path, File::WRONLY | File::APPEND) do |file|
        file.write(',appended-data')
      end

    rescue Errno::ENOENT => ex
      raise CommandError, ex.message
    end

    def self.activity_descriptor
      :modified
    end

  end
end
