require 'spec_helper'

RSpec.describe Runner::ScriptFileRunner do

  before(:all) do
    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.acronym 'SFR'
    end
  end

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

  class SFRCustomException < StandardError; end

  let(:filename)         { temp_file_name('.yaml') }
  let(:output)           { StringIO.new }
  let(:defaults)         { Command::Defaults.new }
  let(:logger)           { SpecHelperMethods::RecordingLogger.new }
  let(:activity_log)     { SpecHelperMethods::RecordingActivityLog.new }
  let(:dry_run)          { false }

  subject                { described_class.new(filename:, output:, logger:, activity_log:, defaults:, dry_run:) }

  before do
    allow(Command).to receive(:command_classes).and_return([SFRTestCommand1, SFRTestCommand2, SFRTestCommand3])
  end

  def create_file(data)
    data = data.map(&:stringify_keys)

    yaml = YAML.dump(data)
    File.write(filename, yaml)
  end

  it 'should execute one command' do
    create_file([
                  { command: 'sfr_test_command2', name: 'Fred', favorite_color: 'red' },
                ])

    expect_any_instance_of(SFRTestCommand2).to receive(:execute!)

    subject.run

    expect(activity_log.records).to match([
      { activity_type: :test_activity_2, favorite_color: 'red', name: 'Fred',
        timestamp: anything, username: anything,
        caller_process_cmdline: anything, caller_process_name: anything, caller_process_id: anything },
    ])
  end

  it 'should alow you to override default attributes' do
    create_file([
                  { command: 'sfr_test_command2', name: 'Fred', favorite_color: 'red', caller_process_id: -123 },
                ])

    expect_any_instance_of(SFRTestCommand2).to receive(:execute!)

    subject.run

    expect(activity_log.records).to match([
                                            { activity_type: :test_activity_2, favorite_color: 'red', name: 'Fred',
                                              caller_process_id: -123,
                                              timestamp: anything, username: anything,
                                              caller_process_cmdline: anything, caller_process_name: anything },
                                          ])
  end

  it 'should execute return nil to show success' do
    create_file([
                  { command: 'sfr_test_command2', name: 'Fred', favorite_color: 'red' },
                ])

    result = subject.run

    expect(result).to be_nil
  end

  it 'should execute multiple commands' do
    create_file([
                  { command: 'sfr_test_command2', name: 'Fred', favorite_color: 'red' },
                  { command: 'sfr_test_command1', name: 'Wilma' },
                ])

    expect_any_instance_of(SFRTestCommand1).to receive(:execute!)
    expect_any_instance_of(SFRTestCommand2).to receive(:execute!)

    subject.run

    expect(activity_log.records).to match([
      { activity_type: :test_activity_2, favorite_color: 'red', name: 'Fred',
        timestamp: anything, username: anything,
        caller_process_cmdline: anything, caller_process_name: anything, caller_process_id: anything },
      { activity_type: :test_activity_1, name: 'Wilma',
        timestamp: anything, username: anything,
        caller_process_cmdline: anything, caller_process_name: anything, caller_process_id: anything },
   ])
  end

  it 'should handle a validation error and not continue' do
    create_file([
                  { command: 'sfr_test_command2' },
                  { command: 'sfr_test_command2', name: 'Barney', favorite_color: 'blue' },
                ])

    expect_any_instance_of(SFRTestCommand2).not_to receive(:execute!)

    result = subject.run

    expect(result).to eq(1)

    output_lines = output.string.lines
    expect(output_lines).to include(
                                    "The parameters for sfr_test_command2 were invalid:\n",
                                    "  Name can't be blank\n",
                                    "  Favorite color can't be blank\n",
                                    "Terminating script\n",
                                    )

    expect(activity_log.records).to  be_empty
  end

  it 'should return an  error if there are unknown attributes and not continue' do
    create_file([
                  { command: 'sfr_test_command2', self_destruct: true, time: '5 minutes' },
                  { command: 'sfr_test_command2', name: 'Barney', favorite_color: 'blue' },
                ])

    expect_any_instance_of(SFRTestCommand2).not_to receive(:execute!)

    result = subject.run

    expect(result).to eq(2)

    output_lines = output.string.lines
    expect(output_lines).to include(
                                    "Attributes contains unknown keys (self_destruct, time) for sfr_test_command2\n",
                                    "Terminating script\n",
                                    )

    expect(activity_log.records).to  be_empty
  end

  it 'should handle an CommandError raised by `execute!` and not continue' do
    create_file([
                  { command: 'sfr_test_command3', name: 'badname' },
                  { command: 'sfr_test_command2', name: 'Barney', favorite_color: 'blue' },
                ])

    result = subject.run
    expect(result).to eq(1)

    output_lines = output.string.lines
    expect(output_lines).to include("An exception occurred: A command error\n",
                                    "Terminating script\n"
                                   )

    expect(activity_log.records).to  be_empty
  end

  it 'should handle an invalid command name and not continue' do
    create_file([
                  { command: 'not_a_command', name: 'Fred', favorite_color: 'red' },
                  { command: 'sfr_test_command2', name: 'Barney', favorite_color: 'blue' },
                ])

    expect_any_instance_of(SFRTestCommandBase).not_to receive(:execute!)

    result = subject.run
    expect(result).to eq(2)

    output_lines = output.string.lines
    expect(output_lines).to include(%{Unknown command name "not_a_command"\n},
                                    "  Valid command_names are: sfr_test_command1, sfr_test_command2, sfr_test_command3\n",
                                    "Terminating script\n"
                                   )

    expect(activity_log.records).to be_empty
  end

  it 'should handle a missing command name  and not continue' do
    create_file([
                  { name: 'Fred', favorite_color: 'red' },
                  { command: 'sfr_test_command2', name: 'Barney', favorite_color: 'blue' },
                ])

    expect_any_instance_of(SFRTestCommandBase).not_to receive(:execute!)

    result = subject.run
    expect(result).to eq(2)

    output_lines = output.string.lines
    expect(output_lines).to include(%{Unknown command name ""\n},
                                    "  Valid command_names are: sfr_test_command1, sfr_test_command2, sfr_test_command3\n",
                                    "Terminating script\n"
                                   )

    expect(activity_log.records).to be_empty
  end

  it 'should praise other errors so that we can debug the call stack' do
    create_file([
                  { command: 'sfr_test_command2', name: 'Barney', favorite_color: 'blue' },
                ])

    expect(logger).to receive(:info).and_raise(SFRCustomException, 'Something went wrong')
    expect_any_instance_of(SFRTestCommandBase).not_to receive(:execute!)

    expect {
      subject.run
    }.to raise_exception(SFRCustomException)

    output_lines = output.string.lines
    expect(output_lines).to include("Error: Something went wrong (SFRCustomException)\n",
                                    "Terminating script\n"
                                   )

    expect(activity_log.records).to be_empty
  end

  describe 'with dry_run set to true' do

    let(:dry_run)          { true }

    it 'should not execute the command' do
      create_file([
                    { command: 'sfr_test_command2', name: 'Fred', favorite_color: 'red' },
                  ])

      expect_any_instance_of(SFRTestCommand2).not_to receive(:execute!)

      subject.run

      expect(activity_log.records).to match([
                                              { activity_type: :test_activity_2, favorite_color: 'red', name: 'Fred',
                                                timestamp: anything, username: anything,
                                                caller_process_cmdline: anything, caller_process_name: anything, caller_process_id: anything },
                                            ])

    end

  end

end
