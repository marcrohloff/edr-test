
module Command
  module Errors

    class CommandError < StandardError
      def quiet_exception; end
    end

  end
end
