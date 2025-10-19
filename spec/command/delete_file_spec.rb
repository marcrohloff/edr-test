require 'fileutils'

require 'spec_helper'
require_relative './shared_activity_examples'
require_relative './shared_file_examples'

RSpec.describe Command::DeleteFile do

  let(:file_path) { temp_file_name }

  subject { described_class.new(timestamp:              123.4,
                                username:               'marc',
                                caller_process_cmdline: '/bin/rspec',
                                caller_process_name:    'rspec',
                                caller_process_id:      456,
                                file_path:) }


  it_behaves_like 'an activity command'
  it_behaves_like 'a file activity'

  describe 'command execution' do

    after do
      FileUtils.rm(file_path, force: true)
    end

    it 'should delete the file' do
      File.write(file_path, 'old-data')

      subject.execute!

      expect(File).not_to be_exist(file_path)
    end

    it 'should raise an exception if the file does not exist' do
      FileUtils.rm(file_path, force: true)
      expect(File).not_to be_exist(file_path)

      expect do
        subject.execute!
      end.to raise_error(described_class::CommandError)
    end

  end

  it 'should generate the correct log info' do
    expect(subject.activity_log_data).to eq(activity_type:        :file_activity,
                                             timestamp:              123.4,
                                             username:               'marc',
                                             caller_process_cmdline: '/bin/rspec',
                                             caller_process_name:    'rspec',
                                             caller_process_id:      456,
                                             activity_descriptor:    'deleted',
                                             file_path:)
  end

end
