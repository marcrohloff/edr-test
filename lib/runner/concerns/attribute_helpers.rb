
module Runner
  module AttributeHelpers

    private

    def default_attribute_value(attribute_name, command)
      if command.attributes[attribute_name.to_s]
        command.attributes[attribute_name.to_s]

      elsif defaults.has?(attribute_name)
        defaults.fetch(attribute_name)

      end
    end

  end
end

