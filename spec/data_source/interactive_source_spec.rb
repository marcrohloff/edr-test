require 'spec_helper'

RSpec.describe DataSource::InteractiveSource do

  let(:command_class) { double('Command') }
  let(:input)         { StringIO.new }
  let(:output)        { StringIO.new }
  let(:defaults)      { DataSource::Defaults.new }
  let(:context)       { double('context', input:, output:, defaults:) }
  let(:subject)       { described_class.new(context:) }

  def set_input(*texts)
    content = texts.join("\n")
    input.puts(content)
    input.rewind
  end

  it 'should ask the user for a value' do
    set_input('user-input')

    allow(command_class).to receive(:attribute_names).and_return([:source_ip])
    response = subject.request(command_class)

    expect(output.string).to eq("Enter a value for Source IP:\n")
    expect(response).to eq(source_ip: 'user-input')
  end

  it 'should return nil for a blank input' do
    set_input('')

    allow(command_class).to receive(:attribute_names).and_return([:source_ip])
    response = subject.request(command_class)

    expect(response).to eq(source_ip: nil)
  end

  it 'should display the default value if there is one' do
    set_input('user-input')

    allow(command_class).to receive(:attribute_names).and_return([:caller_process_id])
    response = subject.request(command_class)

    expect(output.string).to eq("Enter a value for Caller Process ID [#{Process.pid}]:\n")
    expect(response).to eq(caller_process_id: 'user-input')
  end

  it 'should return the default if there is one and the user enters nothing' do
    set_input('')

    allow(command_class).to receive(:attribute_names).and_return([:caller_process_id])
    response = subject.request(command_class)

    expect(response).to eq(caller_process_id: Process.pid)
  end

  it 'should return multiple values' do
    set_input('user-source-ip', 'user-source-port')

    allow(command_class).to receive(:attribute_names).and_return([:source_ip, :source_port])
    response = subject.request(command_class)

    expect(output.string).to eq("Enter a value for Source IP:\nEnter a value for Source Port:\n")
    expect(response).to eq(source_ip: 'user-source-ip', source_port: 'user-source-port')
  end

end
