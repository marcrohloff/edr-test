# A base command to create a delay in a script
#
# This is a simple demo command that might be used from scripts but
# does not generate any activity.

module Command
  class Wait < Base
    attribute :delay, :float

    validates :delay,
              presence: true,
              numericality: { greater_than_or_equal_to: 0 }

    # Delay
    def execute!
      sleep(delay)
    end

  end
end
