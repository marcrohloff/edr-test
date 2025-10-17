module Command
  module FileConcern
    extend ActiveSupport::Concern

    included do
      attribute   :file_path,           :string
      attr_reader :activity_descriptor # output only value

      validates :file_path, :activity_descriptor,
                presence: true
    end

    def initialize(...)
      super
      @activity_descriptor ||= self.class.activity_descriptor.to_s
    end

    def activity_log_entry
      super.merge(activity_descriptor:)
    end

  end
end
