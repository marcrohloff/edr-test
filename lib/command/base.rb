# Base class for all commands
#
# Provides support for degining attributes and validations using `ActiveModel`
# Adds an `export!` method that should be over-riden by subclasses to provide the actual functionality

module Command
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    include Command::Errors

    # Get the command name to use in script inputs, logs and output
    def self.command_name
      name.demodulize.underscore.to_sym
    end

    delegate :command_name,
             to: :class

    # Over-ride to implement the Command's action
    def execute!
      raise NoMethodError
    end


  end
end
