module ActivityLog
  module FileHandleConcern
    extend ActiveSupport::Concern

    included do
      attr_reader :file
    end

    def file_handle
      @file_handle ||= if file.is_a?(String)
                         @file_handle_owned = true
                         File.open(file, file_open_mode)
                       else
                         @file_handle_owned = false
                         file
                       end
    end

    def file_write(data)
      raise(RuntimeError, 'File Handle already allocated') if @file_handle

      begin
        file_handle.write(data)
      ensure
        close_file_handle
      end
    end

    def close_file_handle
      @file_handle.close if @file_handle_owned && @file_handle
      @file_handle = nil
    end

    def file_open_mode
      File::WRONLY | File::CREAT
    end

  end
end
