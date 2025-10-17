module Command
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    class CommandError < StandardError; end

    attribute :timestamp,            :float
    attribute :username,             :string
    attribute :process_command_line, :string
    attribute :process_id,           :integer

    validates :timestamp, :username, :process_command_line, :process_id,
              presence: true

    def initialize(...)
      super
      self.timestamp ||= Time.now.to_f
    end

    def activity_log_entry
      attributes.deep_symbolize_keys
    end

  end
end
