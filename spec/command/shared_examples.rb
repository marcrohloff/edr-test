RSpec.shared_examples 'common command specs' do
  base_attributes = %i[timestamp username
                       caller_process_cmdline caller_process_name caller_process_pid]

  describe 'attributes' do

    it 'should have the common attributes' do
      expect(described_class.attribute_names).to include(*base_attributes.map(&:to_s))
    end

    describe 'validation of common attributes' do

      it 'should be valid' do
        expect(subject).to be_valid
      end

      base_attributes.each do |attribute_name|
        it "should require #{attribute_name} to be set" do
          subject.assign_attributes(attribute_name => nil)

          expect(subject).to be_invalid
          expect(subject.errors).to be_of_kind(attribute_name, :blank)
        end
      end

    end

  end

end
