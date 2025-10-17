require 'fileutils'

require 'spec_helper'

RSpec.describe ActivityLog::JsonFile do

  let(:filename) { temp_file_name }

  def generate_data(activity_log)
    activity_log.start
    activity_log.record(a: 1, b: 2)
    activity_log.record(a: 3, b: 4, c: 6)
    activity_log.record(b: 7, c: 8)
    activity_log.finish
  end

  def validate_log(file_content)
    json = JSON.parse(file_content)

    expect(json).to eq([
                         { 'a' => 1, 'b' => 2 },
                         { 'a' => 3, 'b' => 4, 'c' => 6 },
                         { 'b' => 7, 'c' => 8 },
                       ])
  end

  it 'should save data in the correct format using an IO stream' do
    file = StringIO.new
    activity_log = described_class.new(file)
    generate_data(activity_log)

    validate_log(file.string)
  ensure
    file && file.close
  end

  it 'should save data in the correct format using a filename' do
    activity_log = described_class.new(filename)
    generate_data(activity_log)

    expect(File).to be_exist(filename)
    validate_log(File.read(filename))

  ensure
    FileUtils.rm(filename, force: true)
  end

end
