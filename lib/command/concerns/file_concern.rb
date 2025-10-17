module Command
  module FileConcern
    extend ActiveSupport::Concern

    included do
      attribute :file_path,           :string
      attribute :activity_descriptor, :string

      validates :file_path, :activity_descriptor,
                presence: true
    end

    def initialize(...)
      super
      self.activity_descriptor ||= self.class.activity_descriptor
    end

  end
end
