RSpec.shared_examples 'an activity command' do

  base_attributes = %i[timestamp username
                       caller_process_cmdline caller_process_name caller_process_id]

  describe 'attributes' do

    it 'should have the common attributes' do
      expect(described_class.attribute_names).to include(*base_attributes.map(&:to_s))
    end

    it 'should not have an activity_type attribute' do
      expect(described_class.attribute_names).not_to include('activity_type')
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
