require 'spec_helper'

RSpec.describe Runner::SingleCommandRunner do

  let(:defaults)         { DataSource::Defaults.new }
  let(:logger)           { SpecHelperMethods::RecordingLogger.new }
  let(:activity_log)     { SpecHelperMethods::RecordingActivityLog.new }
  let(:dry_run)          { false }
  let(:context)          { double('context', logger:, activity_log:, defaults:, dry_run:) }

  let(:hash_data)        { { name: 'johndoe' } }
  let(:data_source)      { DataSource::HashSource.new(hash_data, context:) }

  RSpec.shared_examples 'all commands' do

    it 'should create a command instance and execute it' do
      expect(command_instance).to receive(:execute!)
      subject.run
    end

    it 'should fail if validation fails' do
      hash_data.delete(:name)

      expect(command_instance).not_to receive(:execute!)

      expect {
        subject.run
      }.to raise_error(ActiveModel::ValidationError)

      expect(activity_log.records).to be_empty
    end

  end

  context 'Activity commands' do

    class SCRTestActivityCommand < Command::Base
      include Command::ActivityConcern
      attribute :name, :string
      validates :name, presence: true
      def self.activity_type = :test_activity
      def execute!; end
    end

    let(:command_class)    { SCRTestActivityCommand }
    let(:command_instance) { command_class.new }
    subject                { described_class.new(command_class, data_source, context) }

    before do
      command_instance # Make sure it is created before we hook the new method

      expect(command_class).to receive(:new).and_invoke( ->(**attributes) do
        command_instance.assign_attributes(**attributes)
        command_instance
      end)
    end

    it_behaves_like 'all commands'

    it 'should add to the activity log' do
      subject.run

      activity = activity_log.records.sole
      expect(activity).to include(name: 'johndoe')
    end

    describe 'if dry_run is true' do
      let(:dry_run) { true }

      it 'should not run the command but should still log the activity' do
        expect(command_instance).not_to receive(:execute!)

        subject.run

        activity = activity_log.records.last
        expect(activity).to include(name: 'johndoe')
      end

    end

  end

  context 'non-activity commands' do

    class SCRTestBaseCommand < Command::Base
      attribute :name, :string
      validates :name, presence: true
      def execute!; end
    end

    let(:command_class)    { SCRTestBaseCommand }
    let(:command_instance) { command_class.new }
    subject                { described_class.new(command_class, data_source, context) }

    before do
      command_instance # Make sure it is created before we hook the new method

      expect(command_class).to receive(:new).and_invoke( ->(**attributes) do
        command_instance.assign_attributes(**attributes)
        command_instance
      end)
    end

    it_behaves_like 'all commands'

    it 'should not add to the activity log' do
      subject.run

      expect(activity_log.records).to be_empty
    end

    describe 'if dry_run is true' do
      let(:dry_run) { true }

      it 'should not run the command' do
        expect(command_instance).not_to receive(:execute!)

        subject.run

        expect(activity_log.records).to be_empty
      end

    end

  end

end
