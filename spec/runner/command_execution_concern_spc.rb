require 'spec_helper'

RSpec.describe Runner::CommandExecution do

  CommandExecutionClass = Data.define(:logger, :activity_log, :dry_run) do
    include Runner::CommandExecution
    public :execute_command
  end

  let(:logger)           { SpecHelperMethods::RecordingLogger.new }
  let(:activity_log)     { SpecHelperMethods::RecordingActivityLog.new }
  let(:dry_run)          { false }
  subject                { CommandExecutionClass.new(logger:, activity_log:, dry_run:) }

  RSpec.shared_examples 'all commands' do

    it 'should create a command instance and execute it' do
      expect(command_instance).to receive(:execute!)

      result = subject.execute_command(command_instance)

      expect(result).to be_truthy
    end

    it 'should fail if validation fails' do
      command_instance.name = nil
      expect(command_instance).not_to receive(:execute!)

      result = subject.execute_command(command_instance)

      expect(result).to be_falsey
      expect(activity_log.records).to be_empty
    end

  end

  context 'Activity commands' do

    class CETestActivityCommand < Command::Base
      include Command::ActivityConcern
      attribute :name, :string
      validates :name, presence: true
      def self.activity_type = :test_activity
      def execute!; end
    end

    let(:base_attributes)  { { username: 'admin', caller_process_id: 123, caller_process_cmdline: '/bin/cmd', caller_process_name: 'cmd' } }
    let(:command_class)    { CETestActivityCommand }
    let(:command_instance) { command_class.new(**base_attributes, name: 'johndoe') }

    it_behaves_like 'all commands'

    it 'should add to the activity log' do
      result = subject.execute_command(command_instance)

      expect(result).to be_truthy
      expect(activity_log.records).to be_present
      expect(activity_log.records.sole).to include(name: 'johndoe')
    end

    describe 'if dry_run is true' do
      let(:dry_run) { true }

      it 'should not run the command but should still log the activity' do
        expect(command_instance).not_to receive(:execute!)

        subject.execute_command(command_instance)

        expect(activity_log.records).to be_present
        expect(activity_log.records.sole).to include(name: 'johndoe')
      end

    end

  end

  context 'non-activity commands' do

    class CETestBaseCommand < Command::Base
      attribute :name, :string
      validates :name, presence: true
      def execute!; end
    end

    let(:command_class)    { CETestBaseCommand }
    let(:command_instance) { command_class.new(name: 'johndoe') }

    it_behaves_like 'all commands'

    it 'should not add to the activity log' do
      subject.execute_command(command_instance)

      expect(activity_log.records).to be_empty
    end

    describe 'if dry_run is true' do
      let(:dry_run) { true }

      it 'should not run the command' do
        expect(command_instance).not_to receive(:execute!)

        subject.execute_command(command_instance)

        expect(activity_log.records).to be_empty
      end

    end

  end

end
