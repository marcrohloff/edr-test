require 'optparse'
require 'fileutils'

class CommandLineParser

  attr_reader :options, :argv

  def initialize(argv)
    @argv    = argv.dup
  end

  def call
    parse_options!

    if options.help
      display_help
    else
      runner.run
    end
  end

  private

  AppOptions = Struct.new(
    :activity_log,
    :logger,
    :dry_run,
    :help,
  )

  def parse_options!
    @options = AppOptions.new(
      activity_log: 'log/activity.log.json',
      logger:       'log/edr-test.log',
      dry_run:      false,
      help:         false,
    )

    option_parser.parse!
    options.freeze
  end

  def display_help
    output.puts option_parser
  end

  def option_parser
    OptionParser.new do |parser|
      parser.banner = "Usage: edr-test.rb [options]"
      parser.separator ""

      parser.on('-o', '--activity_log FILEPATH',
                "Output activity to the given path (default: #{options.activity_log})") do |fn|
        options.activity_log = fn
      end

      parser.on('-l', '--logger FILEPATH',
                "Log to the given path (default: #{options.logger})") do |fn|
        options.logger  = fn
      end

      parser.on("-x", "--dryrun",
                "Dry run without executing commands") do
        options.dry_run = true
      end

      parser.on("-h", "--help", "Prints this help") do
        options.help = true
      end

      parser.separator ""
    end
  end

  def runner
    @runner ||= Runner::InteractiveRunner.new(
                                              input:,
                                              output:,
                                              logger:,
                                              activity_log:,
                                              defaults:,
                                              dry_run: options.dry_run,
                                             )
  end

  def logger
    log_file = options.logger
    ensure_directory(log_file)
    @logger ||= Logger.new(log_file)
  end

  def activity_log
    interactive_log = ActivityLog::InteractiveOutput.new(output)

    log_file = options.activity_log
    ensure_directory(log_file)
    json_stream_log = ActivityLog::JsonStream.new(log_file)

    Multiplexer.new(interactive_log, json_stream_log)
  end

  def defaults
    Command::Defaults.new
  end

  def input
    $stdin
  end

  def output
    $stdout
  end

  def ensure_directory(filename)
    dir = File.dirname(filename)
    FileUtils.mkdir_p(dir) if dir.present?
  end

end
