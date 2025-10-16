require_relative 'concerns/abstractable'

module Command
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :timestamp,            :integer
    attribute :username,             :string
    attribute :process_command_line, :string
    attribute :process_id,           :integer

    validates :timestamp, :username, :process_command_line, :process_id,
              presence: true
  end
end
