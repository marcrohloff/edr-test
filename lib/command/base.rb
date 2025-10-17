require_relative 'concerns/abstractable'

module Command
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON

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

    def activity_log
      as_json.deep_symbolize_keys
    end

  end
end
