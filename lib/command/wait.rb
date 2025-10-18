module Command
  class Wait < Base
    attribute :delay, :float

    validates :delay,
              presence: true,
              numericality: { greater_than_or_equal_to: 0 }

    def execute!
      sleep(delay)
    end

  end
end
