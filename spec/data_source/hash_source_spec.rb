require 'spec_helper'

RSpec.describe DataSource::HashSource do

  let(:command_class) { double('Command') }
  let(:defaults)      { DataSource::Defaults.new }
  let(:context)       { double('context', defaults:) }
  let(:hash_data)     { { a: 1, b: 2, d: 3 } }
  let(:subject)       { described_class.new(hash_data, context:) }

  it 'should return a set of values from the hash' do
    allow(command_class).to receive(:attribute_names).and_return([:a, :b, :d])
    response = subject.attributes_for(command_class)
    expect(response).to eq(a: 1, b: 2, d: 3)
  end

  it 'should return default values for keys that have defaults' do
    allow(command_class).to receive(:attribute_names).and_return([:a, :b, :d, :username])
    response = subject.attributes_for(command_class)
    expect(response).to eq(a: 1, b: 2, d: 3, username: Etc.getlogin)
  end

  it 'should return nil for keys that are not in the hash data' do
    allow(command_class).to receive(:attribute_names).and_return([:a, :b, :c, :d])
    response = subject.attributes_for(command_class)
    expect(response).to eq(a: 1, b: 2, c: nil, d: 3)
  end

  it 'should raise an exception if there are unused keys in the hash' do
    allow(command_class).to receive(:attribute_names).and_return([:a, :d, :username])

    expect {
      subject.attributes_for(command_class)
    }.to raise_error(described_class::DataSourceError)
  end

end
