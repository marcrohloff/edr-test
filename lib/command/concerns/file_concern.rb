# A concern to be mixed into `Command`s that are file commands
#
# This concern provides for an activity_descriptor and other common attributes

module Command
  module FileConcern
    extend ActiveSupport::Concern

    included do
      attribute   :file_path,           :string
      attr_reader :activity_descriptor # output only value

      validates :file_path, :activity_descriptor,
                presence: true
    end

    class_methods do
      def activity_type = :file_activity
    end

    def initialize(...)
      super
      @activity_descriptor ||= self.class.activity_descriptor.to_s
    end

    def activity_log_data
      super.merge(activity_descriptor:)
    end

  end
end
