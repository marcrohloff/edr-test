require 'fileutils'

require 'spec_helper'
require_relative './shared_examples'
require_relative './shared_file_examples'

RSpec.describe Command::CreateFile do

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

    it 'should create a new file if none exists' do
      FileUtils.rm(file_path, force: true)
      expect(File).not_to be_exist(file_path)

      subject.execute!

      expect(File).to be_exist(file_path)
      expect(File.read(file_path)).to eq('file-data')
    end

    it 'should overwrite the file if it already exists' do
      File.write(file_path, 'old-data')

      subject.execute!

      expect(File).to be_exist(file_path)
      expect(File.read(file_path)).to eq('file-data')
    end

  end

  it 'should generate the correct log info' do
    expect(subject.activity_log_entry).to eq(timestamp:            123.4,
                                       username:             'marc',
                                       process_command_line: '/bin/rspec',
                                       process_id:           456,
                                       activity_descriptor:  'created',
                                       file_path:)
  end

end
