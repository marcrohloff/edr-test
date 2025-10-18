####################################
# Proof of concept

module Runner
  class ScriptRunner < Base

    def run
      file.each_line do |line|
        line_data = parse_line(line)
        run_one(line_data)
      end
    end

    private

    def run_one(line_data)
      command_class = extract_command(line_data)

      data_source = DataSource::HashSource.new(line_data, context:)
      runner = SingleCommandRunner.new(command_class, context)
      runner.run
    end

  end
end
