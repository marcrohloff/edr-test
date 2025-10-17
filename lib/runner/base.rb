module Runner
  class Base

    class RunnerException < StandardError; end

    attr_reader :context

    def initialize(context)
      @context = context
    end

    private

    delegate :logger,
             to: :context, private: true

  end

end

