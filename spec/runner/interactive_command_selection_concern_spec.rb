require 'spec_helper'

RSpec.describe Runner::Interactive::CommandSelection do

  class ICSCommandOne; end
  class ICSCommandTwo; end

  InteractiveCommandSelectionClass = Data.define(:input, :output) do
    include Runner::Interactive::CommandSelection
    public :select_command_class
    def command_classes = [ICSCommandOne, ICSCommandTwo]
  end

  let(:input)         { StringIO.new }
  let(:output)        { StringIO.new }
  subject             { InteractiveCommandSelectionClass.new(input:, output:) }

  def set_input(*texts)
    texts.each { input.puts(it) }
    input.rewind
  end

  before(:all) do
    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.acronym 'ICS'
    end
  end

  it 'should ask the class and return it' do
    set_input('2')

    response = subject.select_command_class
    expect(response).to eq(ICSCommandTwo)

    lines = output.string.lines
    expect(lines).to include(
                             "Available commands:\n",
                             "  (1) ICS Command One\n",
                             "  (2) ICS Command Two\n",
                             "Choose a command number [enter to quit]:\n",
                            )
  end

  it 'should return nil if the user just presses enter' do
    set_input('')

    response = subject.select_command_class
    expect(response).to be_nil
  end

  it 'should retry if the user enters less than one' do
    set_input(0, 2)

    response = subject.select_command_class

    expect(response).to eq(ICSCommandTwo)

    lines = output.string.lines
    expect(lines).to include("Choose a command number [enter to quit]:\n",
                             "Invalid command number. Please try again:\n")
  end

  it 'should retry if the user enters a number that is larger than the number of items' do
    set_input(4, 2)

    response = subject.select_command_class

    expect(response).to eq(ICSCommandTwo)

    lines = output.string.lines
    expect(lines).to include("Choose a command number [enter to quit]:\n",
                             "Invalid command number. Please try again:\n")
  end

  it 'should retry if the user enters an invalid  string' do
    set_input('abcd', 2)

    response = subject.select_command_class

    expect(response).to eq(ICSCommandTwo)

    lines = output.string.lines
    expect(lines).to include("Choose a command number [enter to quit]:\n",
                             "Invalid command number. Please try again:\n")
  end

end
