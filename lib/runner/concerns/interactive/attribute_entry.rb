module Runner
  module Interactive
    module AttributeEntry
      extend ActiveSupport::Concern
      include Runner::AttributeHelpers

      private

      def assign_attributes(command)
        attribute_names = command.attribute_names.map(&:to_sym)

        # Setting attributes one by one so attributes can have side effects that cascade to later attributes
        attribute_names.each do |attribute_name|
          value = read_attribute_value(attribute_name, command)
          command.assign_attributes(attribute_name => value)
        end
      end

      def read_attribute_value(attribute_name, command)
        default = default_attribute_value(attribute_name, command)
        display_attribute_prompt(attribute_name, default)

        user_input = input.readline.chomp
        user_input.presence || default
      end

      def display_attribute_prompt(attribute_name, default)
        prompt  = ['Enter a value for ',
                   human_attribute_name(attribute_name),
                   (" [#{default}]" if default.present?),
                   ':'
                  ].compact.join('')

        output.puts(prompt)
      end

      def human_attribute_name(attribute_name)
        attribute_name.to_s
                      .humanize(keep_id_suffix: true)
                      .titleize(keep_id_suffix: true)
      end

    end
  end
end
