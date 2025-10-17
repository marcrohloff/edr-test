require 'spec_helper'
require_relative './shared_examples'

RSpec.describe Command::Base do

  subject { described_class.new(timestamp:              123.4,
                                username:               'marc',
                                caller_process_cmdline: '/bin/rspec',
                                caller_process_name:    'rspec',
                                caller_process_pid:     456) }

  include_examples 'common command specs'

  it 'should return the set of command_classes' do
    expect(described_class.command_classes).to contain_exactly(
                                                 Command::StartProcess,
                                                 Command::CreateFile,
                                                 Command::ModifyFile,
                                                 Command::DeleteFile,
                                                 Command::NetworkConnection,
                                               )

  end

end
