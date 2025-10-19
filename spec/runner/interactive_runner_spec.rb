require 'spec_helper'

RSpec.describe Runner::InteractiveRunner do

  class SFRTestCommandBase < Command::Base
    include Command::ActivityConcern
    attribute :name, :string
    validates :name, presence: true
    def execute!; end
  end

  class SFRTestCommand1 < SFRTestCommandBase
    def self.activity_type = :test_activity_1
  end

  class SFRTestCommand2 < SFRTestCommandBase
    attribute :favorite_color, :string
    validates :favorite_color, presence: true
    def execute!; end
    def self.activity_type = :test_activity_2
  end

  class SFRTestCommand3 < SFRTestCommandBase
    def execute!; raise(CommandError, 'A command error') if name =='badname'; end
    def self.activity_type = :test_activity_3
  end

  let(:input)            { StringIO.new }
  let(:output)           { StringIO.new }
  let(:defaults)         { Command::Defaults.new }
  let(:logger)           { SpecHelperMethods::RecordingLogger.new }
  let(:activity_log)     { SpecHelperMethods::RecordingActivityLog.new }
  let(:dry_run)          { false }

  subject                { described_class.new(input:, output:, logger:, activity_log:, defaults:, dry_run:) }

  def set_input(*texts)
    texts.each { input.puts(it) }
    input.rewind
  end

  before do
    allow(Command).to receive(:command_classes).and_return([SFRTestCommand1, SFRTestCommand2, SFRTestCommand3])
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

    expect_any_instance_of(SFRTestCommand1).to receive(:execute!)
    expect_any_instance_of(SFRTestCommand2).to receive(:execute!)

    subject.run

    expect(activity_log.records).to eq([
      { activity_type: :test_activity_2, timestamp: 123456.0, username: 'johndoe',
        caller_process_cmdline: '/cmd', caller_process_name: 'cmd', caller_process_id: 123,
        favorite_color: 'red', name: 'Fred' },
      { activity_type: :test_activity_1, timestamp: 123456.0, username: 'johndoe',
        caller_process_cmdline: '/cmd', caller_process_name: 'cmd', caller_process_id: 123,
        name: 'Wilma' },
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

      '',        # quit
      )

    expect_any_instance_of(SFRTestCommand2).not_to receive(:execute!)

    subject.run

    output_lines = output.string.lines
    expect(output_lines).to include(
                                    "The parameters were invalid:\n",
                                    "  Name can't be blank\n",
                                    "  Favorite color can't be blank\n",
                                    "Please try again\n",
                                    )

    expect(activity_log.records).to  be_empty
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

      '',        # quit
    )

    subject.run

    output_lines = output.string.lines
    expect(output_lines).to include(
                                     "An exception occurred: A command error\n",
                                     "Try again\n"
                                    )

    expect(activity_log.records).to  be_empty
  end

  describe 'with dry_run set to true' do

    let(:dry_run)          { true }

    it 'should not execute the command' do
      set_input(
        2,         # Choose TestCommand2
        123456,    # Timestamp
        'johndoe', # username
        '/cmd',    # process cmdline
        'cmd',     # process name
        123,       # process pid
        'Fred',    # name
        'red',     # color

        '',        # quit
        )

      expect_any_instance_of(SFRTestCommand2).not_to receive(:execute!)

      subject.run

      expect(activity_log.records).to eq([
                                           { activity_type: :test_activity_2, timestamp: 123456.0, username: 'johndoe',
                                             caller_process_cmdline: '/cmd', caller_process_name: 'cmd', caller_process_id: 123,
                                             favorite_color: 'red', name: 'Fred' },
                                         ])

    end

  end
end
