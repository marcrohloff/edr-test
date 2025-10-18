module Command
  module ActivityConcern
    extend ActiveSupport::Concern

    included do
      attribute :timestamp,              :float
      attribute :username,               :string
      attribute :caller_process_cmdline, :string
      attribute :caller_process_name,    :string
      attribute :caller_process_pid,     :integer

      validates :timestamp, :username,
                :caller_process_cmdline, :caller_process_name, :caller_process_pid,
                presence: true
    end

    def initialize(...)
      super
      self.timestamp ||= Time.now.to_f
    end

    def activity_log_data
      { activity_type: self.class.activity_type }.merge(attributes.deep_symbolize_keys)
    end

  end
end
