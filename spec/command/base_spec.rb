require 'spec_helper'
require_relative './shared_activity_examples'

RSpec.describe Command::Base do

  it 'should return the set of command_classes' do
    expect(described_class.command_classes).to contain_exactly(
                                                               Command::StartProcess,
                                                               Command::CreateFile,
                                                               Command::ModifyFile,
                                                               Command::DeleteFile,
                                                               Command::NetworkConnection,
                                                               Command::Wait,
                                                              )

  end

end
