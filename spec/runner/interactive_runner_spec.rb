require 'spec_helper'

RSpec.describe Runner::InteractiveRunner do

  class TestCommand < Command::Base
    attribute :name, :string
    validates :name, presence: true
    def execute!; end
  end

  class TestCommand2 < TestCommand
    attribute :favorite_color, :string
    validates :favorite_color, presence: true
    def execute!; end
  end

  class TestCommand3 < TestCommand
    def execute!; raise CommandError if name =='badname'; end
  end

  let(:input)            { StringIO.new }
  let(:output)           { StringIO.new }
  let(:defaults)         { DataSource::Defaults.new }
  let(:logger)           { SpecHelperMethods::RecordingLogger.new }
  let(:activity_log)     { SpecHelperMethods::RecordingActivityLog.new }
  let(:dry_run)          { false }

  let(:context)          { double('context', input:, output:, logger:, activity_log:, defaults:, dry_run:) }
  subject                { described_class.new(context) }

  def set_input(*texts)
    texts.each { input.puts(it) }
    input.rewind
  end

  before do
    allow(Command::Base).to receive(:command_classes).and_return([TestCommand, TestCommand2, TestCommand3])
  end

  it 'should execute multiple commands' do
    set_input(
      2,         # Choose TestCommand2
      123456,    # Timestamp
      'johndoe', # username
      '/cmd',    # process cmdline
      'cmd',     # process name
      123,       # process pid
      'Fred',    # name
      'red',     # color

      1,         # Choose TestCommand2
      123456,    # Timestamp
      'johndoe', # username
      '/cmd',    # process cmdline
      'cmd',     # process name
      123,       # process pid
      'Wilma',   # name

      '',        # quit
    )

    subject.run

    expect(activity_log.records).to eq([
      { caller_process_cmdline: '/cmd', caller_process_name: 'cmd', caller_process_pid: 123,
        favorite_color: 'red', name: 'Fred', timestamp: 123456.0, username: 'johndoe'},
      { caller_process_cmdline: '/cmd', caller_process_name: 'cmd', caller_process_pid: 123,
        name: 'Wilma', timestamp: 123456.0, username: 'johndoe'},
   ])

  end

  it 'should handle a validation error`' do
    set_input(
      2,         # Choose TestCommand2

      1234567,   # Timestamp
      'johndoe', # username
      '/cmd',    # process cmdline
      'cmd',     # process name
      1234,      # process pid
      '',        # name
      '',        # favorite_color
                 # validation error occurs here

      123456,    # Timestamp
      'johndoe', # username
      '/cmd',    # process cmdline
      'cmd',     # process name
      123,       # process pid
      'Fred',    # name
      'Red',     # name

      '',        # quit
      )

    subject.run

    output_lines = output.string.lines
    expect(output_lines).to include(
                                    "The parameters were invalid:\n",
                                    "  Name can't be blank\n",
                                    "  Favorite color can't be blank\n",
                                    "Please try again\n",
                                    )

    expect(activity_log.records).to  eq([
      { caller_process_cmdline: '/cmd', caller_process_name: 'cmd', caller_process_pid: 123,
        favorite_color: 'Red', name: 'Fred', timestamp: 123456.0, username: 'johndoe'},
    ])
  end

  it 'should handle an exception raised by `execute!`' do
    set_input(
      3,         # Choose TestCommand2

      1234567,   # Timestamp
      'johndoe', # username
      '/cmd',    # process cmdline
      'cmd',     # process name
      1234,      # process pid
      'badname', # name
                 # exception raised in `execute!` here


      123456,    # Timestamp
      'johndoe', # username
      '/cmd',    # process cmdline
      'cmd',     # process name
      123,       # process pid
      'Fred',    # name

      '',        # quit
    )

    subject.run

    output_lines = output.string.lines
    expect(output_lines).to include("An exception occurred: Command::Base::CommandError. Try again\n")

    expect(activity_log.records).to  eq([
      { caller_process_cmdline: '/cmd', caller_process_name: 'cmd', caller_process_pid: 123,
        name: 'Fred', timestamp: 123456.0, username: 'johndoe'},
    ])
  end

end
