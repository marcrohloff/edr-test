module Runner
  module Errors

    class RunnerError < StandardError
      def quiet_exception; end
    end

  end
end
