require 'fileutils'

require 'spec_helper'

RSpec.describe ActivityLog::JsonStream do

  let(:filename) { temp_file_name }

  def generate_data(activity_log)
    activity_log.start
    activity_log.record(a: 1, b: 2)
    activity_log.record(a: 3, b: 4, c: 6)
    activity_log.record(b: 7, c: 8)
    activity_log.finish
  end

  def validate_log(file_content)
    lines = file_content.lines

    expect(lines.count).to eq(3)

    json_lines = lines.map { |line| JSON.parse(line) }
    expect(json_lines[0]).to eq('a' => 1, 'b' => 2)
    expect(json_lines[1]).to eq('a' => 3, 'b' => 4, 'c' => 6)
    expect(json_lines[2]).to eq('b' => 7, 'c' => 8)
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
