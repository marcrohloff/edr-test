module Command
  class StartProcess < Base
    attribute :process_name, :string

    validates :process_name,
              presence: true

    def execute!
      # Run the process in the background so that it doesn't block
      pid = Process.spawn(process_name)
      Process.detach(pid)
    end

  end
end
