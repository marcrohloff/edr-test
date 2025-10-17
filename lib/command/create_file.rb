require_relative './concerns/file_concern'

module Command
  class CreateFile < Base
    include FileConcern

    def execute!
      # If the file exists it will be over-written
      File.write(file_path, 'file-data')
    end

    def self.activity_descriptor
      :created
    end

  end
end
