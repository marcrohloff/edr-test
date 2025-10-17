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

    def self.command_classes
      # Note: I intended to keep this flexible by calling `subclasses`
      #       (with some potential filtering required)
      #       However the responses are ordered in reverse alphabetical order
      #       And I wanted to stick to the order given in the document
      #       So this is just hard-coded for now

      [
        Command::StartProcess,
        Command::CreateFile,
        Command::ModifyFile,
        Command::DeleteFile,
        Command::NetworkConnection,
      ]
    end

  end
end
