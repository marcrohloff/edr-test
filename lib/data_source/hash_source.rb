module DataSource
  class HashSource < Base

    attr_reader :data, :context

    def initialize(data, context:)
      @data     = data.deep_symbolize_keys
      @context  = context
    end

    def request(command_class)
      attributes = command_class.attribute_names.map(&:to_sym)

      extra_keys = data.keys - attributes
      raise DataSourceError, "Data source contains extra keys #{extra_keys}" if extra_keys.present?

      attributes.index_with do |attribute_name|
        attribute_value(attribute_name)
      end
    end

    private

    delegate :defaults, to: :context

    def attribute_value(attribute_name)
      if data.key?(attribute_name)
        data[attribute_name]
      else
        defaults.lookup(attribute_name)
      end
    end

  end
end
