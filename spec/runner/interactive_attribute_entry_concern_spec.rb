require 'spec_helper'

RSpec.describe Runner::InteractiveAttributeEntry do

  InteractiveAttributeEntryClass = Data.define(:input, :output, :defaults) do
    include Runner::InteractiveAttributeEntry
    public :assign_attributes
  end

  class IAETestCommand < Command::Base
    attribute :caller_process_id,  :integer
    attribute :source_address,     :string
    attribute :source_port,        :integer
  end

  let(:command)       { IAETestCommand.new }
  let(:input)         { StringIO.new }
  let(:output)        { StringIO.new }
  let(:defaults)      { Command::Defaults.new }
  subject             { InteractiveAttributeEntryClass.new(input:, output:, defaults:) }

  def set_input(*texts)
    texts.each { input.puts(it) }
    input.rewind
  end

  it 'should ask the user for a value and set it' do
    set_input('user-input')

    allow(command).to receive(:attribute_names).and_return([:source_address])
    subject.assign_attributes(command)

    expect(output.string).to eq("Enter a value for Source Address:\n")
    expect(command.source_address).to eq('user-input')
  end

  it 'should set the value to nil for a blank input' do
    set_input('')

    allow(command).to receive(:attribute_names).and_return([:source_address])
    subject.assign_attributes(command)

    expect(command.source_address).to be_nil
  end

  it 'should display the default value if there is one' do
    set_input('123')

    allow(command).to receive(:attribute_names).and_return([:caller_process_id])
    subject.assign_attributes(command)

    expect(output.string).to eq("Enter a value for Caller Process ID [#{Process.pid}]:\n")
    expect(command.caller_process_id).to eq(123)
  end

  it 'should set the default if there is one and the user enters nothing' do
    set_input('')

    allow(command).to receive(:attribute_names).and_return([:caller_process_id])
    subject.assign_attributes(command)

    expect(command.caller_process_id).to eq(Process.pid)
  end

  it 'should prefer the current value over the default (if there is one)' do
    set_input('')
    command.caller_process_id = 789

    allow(command).to receive(:attribute_names).and_return([:caller_process_id])
    subject.assign_attributes(command)

    expect(command.caller_process_id).to eq(789)
  end

  it 'should return multiple values' do
    set_input('user-source-port', '443')

    allow(command).to receive(:attribute_names).and_return([:source_address, :source_port])
    subject.assign_attributes(command)

    expect(output.string).to eq("Enter a value for Source Address:\nEnter a value for Source Port:\n")
    expect(command.source_address).to eq('user-source-port')
    expect(command.source_port).to eq(443)
  end

end
