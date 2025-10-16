RSpec.shared_examples 'common command specs' do

  it 'should have the common attributes' do
    expect(described_class.attribute_names).to include('timestamp', 'username', 'process_command_line', 'process_id')
  end

end
