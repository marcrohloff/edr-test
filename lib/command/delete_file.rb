require 'fileutils'

# Activity Command to delete a file

module Command
  class DeleteFile < Base
    include ActivityConcern
    include FileConcern

    # Delete the file
    def execute!
      # Raise an exception if the file doesn't exist
      FileUtils.rm(file_path)
    rescue Errno::ENOENT => ex
      raise CommandError, ex.message
    end

    def self.activity_descriptor
      :deleted
    end

  end
end

