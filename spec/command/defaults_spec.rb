require 'spec_helper'

RSpec.describe Command::Defaults do

  describe '#has??' do

    it 'should return true for keys in the lookup tale' do
      expect(subject.has?(:timestamp)).to be_truthy
      expect(subject.has?(:caller_process_pid)).to be_truthy
    end

    it 'should return false for keys that are not in the lookup table' do
      expect(subject.has?(:not_an_attribute)).to be_falsey
    end

  end

  describe '#fetch' do

    it 'should provide a default for timestamp' do
      expect(subject.fetch(:timestamp)).to be_within(0.01).of(Time.now.to_f)
    end

    it 'should provide a default for the username' do
      expect(subject.fetch(:username)).to eq(Etc.getlogin)
    end

    it 'should provide a default for the caller_process_cmdline' do
      expect(subject.fetch(:caller_process_cmdline)).to match(/\/rspec(\s|$)/)
    end

    it 'should provide a default for the caller_process_name' do
      expect(subject.fetch(:caller_process_name)).to match(/\/rspec(\s|$)/)
    end

    it 'should provide a default for the caller_process_pid' do
      expect(subject.fetch(:caller_process_pid)).to match(Process.pid)
    end

    it 'should return nil for an unknown key' do
      expect(subject.fetch(:not_an_attribute)).to be_nil
    end

  end

end
