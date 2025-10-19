# Helpers for working with attribute values

module Runner
  module AttributeHelpers
    extend ActiveSupport::Concern

    private

    # Get the default to use for an attribute's value
    #
    # Use the current value or else the value from the defaults lookup
    #
    # @param attribute_name [Symbol]  The attribute name to get the default for
    # @param command        [Command] The command we are getting the default for
    def default_attribute_value(attribute_name, command)
      if command.attributes[attribute_name.to_s]
        command.attributes[attribute_name.to_s]

      elsif defaults.has?(attribute_name)
        defaults.fetch(attribute_name)

      end
    end

  end
end

