require 'fileutils'

require 'spec_helper'
require_relative './shared_activity_examples'
require_relative './shared_file_examples'

RSpec.describe Command::ModifyFile do

  let(:file_path) { temp_file_name }

  subject { described_class.new(timestamp:              123.4,
                                username:               'marc',
                                caller_process_cmdline: '/bin/rspec',
                                caller_process_name:    'rspec',
                                caller_process_pid:     456,
                                file_path:) }


  it_behaves_like 'an activity command'
  it_behaves_like 'a file activity'

  describe 'command execution' do

    after do
      FileUtils.rm(file_path, force: true)
    end

    it 'should append data to the file' do
      File.write(file_path, 'original-data')

      subject.execute!

      expect(File).to be_exist(file_path)
      expect(File.read(file_path)).to eq('original-data,appended-data')
    end

    it 'should append data to the file multiple times' do
      File.write(file_path, 'original-data')

      subject.execute!

      command2 = described_class.new(subject.attributes)
      command2.execute!

      expect(File).to be_exist(file_path)
      expect(File.read(file_path)).to eq('original-data,appended-data,appended-data')
    end

    it 'should raise an exception if the file does not exist' do
      FileUtils.rm(file_path, force: true)

      expect do
        subject.execute!
      end.to raise_error(described_class::CommandError)

      expect(File).not_to be_exist(file_path)
    end

  end

  it 'should generate the correct log info' do
    expect(subject.activity_log_entry).to eq(activity_type:        :file_activity,
                                             timestamp:              123.4,
                                             username:               'marc',
                                             caller_process_cmdline: '/bin/rspec',
                                             caller_process_name:    'rspec',
                                             caller_process_pid:     456,
                                             activity_descriptor:    'modified',
                                             file_path:)
  end

end
