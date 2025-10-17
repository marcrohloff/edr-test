require 'spec_helper'
require_relative './shared_examples'

RSpec.describe Command::StartProcess do
  attributes = %i[process_name]

  subject { described_class.new(timestamp:            123.4,
                                username:             'marc',
                                process_command_line: '/bin/rspec',
                                process_id:           456,
                                process_name:         'test-process') }


  include_examples 'common command specs'

  describe 'attributes' do

    it 'should have the correct attributes' do
      expect(described_class.attribute_names).to include(*attributes.map(&:to_s))
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
      expect(Process).to receive(:spawn).with('test-process').and_return(-1)

      subject.execute!
    end

  end

  it 'should generate the correct log info' do
    expect(subject.activity_log_entry).to eq(timestamp:            123.4,
                                       username:             'marc',
                                       process_command_line: '/bin/rspec',
                                       process_id:           456,
                                       process_name:         'test-process')
  end

end
