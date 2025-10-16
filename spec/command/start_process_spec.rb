require 'spec_helper'
require_relative './shared_examples'

RSpec.describe Command::StartProcess do

  include_examples 'common command specs'

  it 'should have the correct attributes' do
    expect(described_class.attribute_names).to include('process_name')
  end

end
