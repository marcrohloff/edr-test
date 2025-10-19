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

    # Over-ride to implement the Command's action
    def execute!
      raise NoMethodError
    end

  end
end
