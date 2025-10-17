module DataSource
  class InteractiveSource < Base

    attr_reader :context

    def initialize(context:)
      @context = context
    end

    def request(command_class)
      attributes = command_class.attribute_names.map(&:to_sym)

      attributes.index_with do |attribute_name|
        request_value(attribute_name)
      end
    end

    private

    delegate :input, :output, :defaults, to: :context

    def request_value(attribute_name)
      default = defaults.lookup(attribute_name)
      output.puts(prompt_text(attribute_name, default))

      user_input = input.readline.chomp
      user_input.presence || default
    end

    def prompt_text(attribute_name, default)
      prompt  = "Enter a value for #{human_attribute_name(attribute_name)}"
      prompt  += " [#{default}]" if default
      prompt  + ":"
    end

    def human_attribute_name(attribute_name)
      attribute_name.to_s
                    .humanize(keep_id_suffix: true)
                    .titleize(keep_id_suffix: true)
    end

  end
end
