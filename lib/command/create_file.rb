# Activity Command to create a file

module Command
  class CreateFile < Base
    include ActivityConcern
    include FileConcern

    # Create the file
    def execute!
      # If the file exists it will be over-written
      File.write(file_path, 'file-data')
    end

    def self.activity_descriptor
      :created
    end

  end
end
