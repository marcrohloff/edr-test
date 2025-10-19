require 'spec_helper'
require_relative './shared_activity_examples'

RSpec.describe Command::StartProcess do
  attributes = %i[started_process_cmdline]

  subject { described_class.new(timestamp:               123.4,
                                username:                'marc',
                                caller_process_cmdline:  '/bin/rspec',
                                caller_process_name:     'rspec',
                                caller_process_id:       456,
                                started_process_cmdline: 'test-process') }


  it_behaves_like 'an activity command'

  it 'should have the correct command_name' do
    expect(subject.command_name).to eq(:start_process)
  end

  describe 'attributes' do

    it 'should have the correct attributes' do
      expect(described_class.attribute_names).to include(*attributes.map(&:to_s))
    end

    it 'should not have a started_process_id attribute' do
      expect(described_class.attribute_names).not_to include('started_process_id')
    end

    describe 'validation' do

      it 'should be valid' do
        expect(subject).to be_valid
      end

      attributes.each do |attribute_name|
        it "should require #{attribute_name} to be set" do
          subject.assign_attributes(attribute_name => nil)

          expect(subject).to be_invalid
          expect(subject.errors).to be_of_kind(attribute_name, :blank)
        end
      end

    end

  end

  describe 'command execution' do

    it 'should start a process' do
      expect(Process).to receive(:spawn).with('test-process').and_return(1123)
      expect(Process).to receive(:detach).with(1123)

      subject.execute!

      expect(subject.started_process_id).to eq(1123)
    end

  end

  it 'should generate the correct log info' do
    expect(Process).to receive(:spawn).with('test-process').and_return(1123)
    expect(Process).to receive(:detach).with(1123)

    subject.execute!

    expect(subject.activity_log_data).to eq(activity_type:           :process_start,
                                             timestamp:               123.4,
                                             username:                'marc',
                                             caller_process_cmdline:  '/bin/rspec',
                                             caller_process_name:     'rspec',
                                             caller_process_id:       456,
                                             started_process_cmdline: 'test-process',
                                             started_process_id:      1123)
  end

end
