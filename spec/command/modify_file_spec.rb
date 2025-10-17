require 'fileutils'

require 'spec_helper'
require_relative './shared_examples'
require_relative './shared_file_examples'

RSpec.describe Command::ModifyFile do

  let (:file_path) { "/tmp/test-file-#{SecureRandom.uuid_v7}" }

  subject { described_class.new(timestamp:            123.4,
                                username:             'marc',
                                process_command_line: '/bin/rspec',
                                process_id:           456,
                                file_path:) }


  include_examples 'common command specs'
  include_examples 'common file command specs'

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

      command2 = described_class.new(subject.as_json)
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
    expect(subject.activity_log).to eq(timestamp:            123.4,
                                       username:             'marc',
                                       process_command_line: '/bin/rspec',
                                       process_id:           456,
                                       activity_descriptor:  'modified',
                                       file_path:)
  end

end
