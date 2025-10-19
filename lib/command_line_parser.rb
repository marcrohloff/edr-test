require 'optparse'
require 'fileutils'

# Class to parse the command line and run the app

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
      exit_code = runner.run
      exit(exit_code || 0)

    end
  end

  private

  AppOptions = Struct.new(
    :interactive,
    :script_file,
    :activity_log_file,
    :logger_file,
    :dry_run,
    :help,
  )

  def parse_options!
    @options = AppOptions.new(
      interactive:       true, # show interactive ui by defailt
      script_file:       'sample-script.yaml',
      activity_log_file: 'log/activity.log.json',
      logger_file:       'log/edr-test.log',
      dry_run:           false,
      help:              false,
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

      parser.on('-s', '--script [FILEPATH]',
                "Read commands from the given script file (default: #{options.script_file})") do |fn|
        options.interactive = false
        options.script_file = fn if fn.present?
      end

      parser.on('-o', '--activity-log FILEPATH',
                "Output activity to the given path (default: #{options.activity_log_file})") do |fn|
        options.activity_log_file = fn
      end

      parser.on('-l', '--logger FILEPATH',
                "Log to the given path (default: #{options.logger_file})") do |fn|
        options.logger_file  = fn
      end

      parser.on("-x", "--dry-run", "--dryrun",
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
    @runner ||= if options.interactive
                  Runner::InteractiveRunner.new(input:, output:,
                                                logger:, activity_log:, defaults:,
                                                dry_run: options.dry_run,
                                               )
                else
                  Runner::ScriptFileRunner.new(filename: options.script_file,
                                               output:,
                                               logger:, activity_log:, defaults:,
                                               dry_run: options.dry_run,
                                              )
                end
  end

  def logger
    @logger ||= begin
                  log_file = options.logger_file
                  ensure_directory(log_file)
                  Logger.new(log_file)
                end
  end

  def activity_log
    @activity_log || begin
                       interactive_log = ActivityLog::InteractiveOutput.new(output)

                       log_file = options.activity_log_file
                       ensure_directory(log_file)
                       json_stream_log = ActivityLog::JsonStream.new(log_file)

                       Multiplexer.new(interactive_log, json_stream_log)
                     end
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
