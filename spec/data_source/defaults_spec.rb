require 'spec_helper'

RSpec.describe DataSource::Defaults do

  describe '#contains?' do

    it 'should return true for keys in the lookup tale' do
      expect(subject).to be_contains(:timestamp)
      expect(subject).to be_contains(:caller_process_pid)
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

    it 'should provide a default for the caller_process_cmdline' do
      expect(subject.lookup(:caller_process_cmdline)).to match(/\/rspec(\s|$)/)
    end

    it 'should provide a default for the caller_process_name' do
      expect(subject.lookup(:caller_process_name)).to match(/\/rspec(\s|$)/)
    end

    it 'should provide a default for the caller_process_pid' do
      expect(subject.lookup(:caller_process_pid)).to match(Process.pid)
    end

    it 'should return nil for an unknown key' do
      expect(subject.lookup(:not_an_attribute)).to be_nil
    end

  end

end
