require 'spec_helper'

RSpec.describe DataSource::Defaults do

  describe '#contains?' do

    it 'should return true for keys in the lookup tale' do
      expect(subject).to be_contains(:timestamp)
      expect(subject).to be_contains(:process_id)
    end

    it 'should return false for keys that are not in the lookup table' do
      expect(subject).not_to be_contains(:not_an_attribute)
    end

  end

  describe '#lookup' do

    it 'should provide a default for timestamp' do
      expect(subject.lookup(:timestamp)).to be_within(0.01).of(Time.now.to_f)
    end

    it 'should provide a default for the username' do
      expect(subject.lookup(:username)).to eq(Etc.getlogin)
    end

    it 'should provide a default for the process_command_line' do
      expect(subject.lookup(:process_command_line)).to match(/\/rspec(\s|$)/)
    end

    it 'should provide a default for the process_id' do
      expect(subject.lookup(:process_id)).to eq(Process.pid)
    end

    it 'should return nil for an unknown key' do
      expect(subject.lookup(:not_an_attribute)).to be_nil
    end

  end

end
