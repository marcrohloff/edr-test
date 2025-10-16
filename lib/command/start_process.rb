module Command
  class StartProcess < Base
    attribute :process_name, :string

    validates :process_name,
              presence: true
  end
end
